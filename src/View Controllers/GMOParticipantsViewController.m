//
//  GMOParticipantsViewController.m
//  GauchoMobile
//
//  GMOParticipantsViewController is the base view controller for the People view. It handles loading data,
//  loading and caching images of people enrolled in the class, and handling address book lookups
//  and presentation. Depending on the current device, it adds GMPeopleTableViewController or
//  GMPeopleCollectionViewController as a child view controller, which is responsible for managing
//  the view the user ultimately sees.
//

#import "GMOParticipantsViewController.h"
#import "GMParticipantsTableViewController.h"
#import "GMParticipantsCollectionViewController.h"

@interface GMOParticipantsViewController ()

/* GMOParticipantsViewController does not control any view the user interacts with – it just
 contains common logic and data structures shared between a table view or collection view view
 controller, which is added as a child view controller and is responsible for the view the
 user interacts with. This property is that child view controller. */
@property (retain) UIViewController <GMParticipantsChildViewController> *presentationViewController;

@property (retain) GMSourceFetcher *fetcher;
@property (retain, readwrite) NSMutableDictionary *pictures;
@property (retain, readwrite) NSArray *sections;
@property (assign, readwrite) ABAddressBookRef addressBook;

@end


@implementation GMOParticipantsViewController

@synthesize presentationViewController;
@synthesize fetcher;
@synthesize pictures;
@synthesize sections;
@synthesize addressBook;

#pragma mark -
#pragma mark Setup and teardown

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        NSString *imageDictPath = [self imageDictPath];
        
        /* The images of people enrolled in the class are cached on disk to avoid having to load them
           from the network. If this cache is present, initialize pictures to its contents */
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageDictPath]) {
            pictures = [[NSKeyedUnarchiver unarchiveObjectWithFile:imageDictPath] retain];
        } else {
            pictures = [[NSMutableDictionary alloc] init];
        }

        fetcher = [[GMSourceFetcher alloc] init];
        
        CFErrorRef error = nil;
        addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        sections = [[NSArray alloc] init];
        
        // On the iPad, we want to use the collection view-based view controller to show participants
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            presentationViewController = [[GMParticipantsCollectionViewController alloc] initWithNibName:@"GMParticipantsCollectionViewController" bundle:[NSBundle mainBundle]];
        } else { // And on the iPhone, we use the table view-based variant
            presentationViewController = [[GMParticipantsTableViewController alloc] initWithNibName:@"GMParticipantsTableViewController" bundle:[NSBundle mainBundle]];
        }
    }
    
    return self;
}

- (void)dealloc {
    [pictures release];
    [fetcher release];
    if (addressBook) {
        CFRelease(addressBook);
    }
    
    [presentationViewController willMoveToParentViewController:nil];
    [presentationViewController.view removeFromSuperview];
    [presentationViewController removeFromParentViewController];
    [presentationViewController release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.title = @"People";
    // Clear our right bar button item in case we're switching to People from Assignments
    // (which has an Import button there)
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    // Register for KVO notifications when the current course changes
    [[GMDataSource sharedDataSource] addObserver:self
                                      forKeyPath:@"currentCourse"
                                         options:NSKeyValueObservingOptionNew
                                         context:nil];
    
    // On iOS 6 and newer, we need to request access to contacts from the user
    ABAddressBookRequestAccessWithCompletion(self.addressBook, nil);
    
    // Add the collection or table view VC as a child view controller and add its root view as a subview
    [self addChildViewController:presentationViewController];
    presentationViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:presentationViewController.view];
    [presentationViewController didMoveToParentViewController:self];
    
    [self loadParticipants];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[GMDataSource sharedDataSource] removeObserver:self forKeyPath:@"currentCourse"];
    
    // When our view disappears, cache the contents of the pictures array to disk
    NSData *picsData = [NSKeyedArchiver archivedDataWithRootObject:self.pictures];
    [picsData writeToFile:[self imageDictPath] atomically:YES];
}

#pragma mark -
#pragma mark KVO notifications

/* On the iPad, the current course can be changed while our view is still visible. We listen to KVO
   changes on the data source's current course property, and load participants afresh when it changes */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [presentationViewController reloadData];
    [self loadParticipants];
}

#pragma mark -
#pragma mark Data loading

- (void)loadParticipants {
    GMCourse *currentCourse = [GMDataSource sharedDataSource].currentCourse;
    
    // If the current course doesn't have any participants, try to fetch the list from GauchoSpace
    if ([currentCourse.participants count] == 0) {
        [presentationViewController loadingStarted];
        [fetcher participantsForCourse:currentCourse withDelegate:self];
    } else {
        /* Otherwise, we already have fetched the list, so just update our display to reflect the
           list of participants already in memory */
        [self updateSections];
        [presentationViewController reloadData];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    [presentationViewController loadingFinished];
    [presentationViewController reloadData];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error loading people"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    GMParticipantsParser *parser = [[GMParticipantsParser alloc] init];
    
    // Extract the participants from the GauchoSpace page
    NSArray *participants = [parser participantsFromSource:source];
    
    // Add each one to the current course
    for (GMParticipant *participant in participants) {
        [[GMDataSource sharedDataSource].currentCourse addParticipant:participant];
    }
    
    [parser release];
    
    [self updateSections];
    
    [presentationViewController loadingFinished];
    [presentationViewController reloadData];

    [self loadPicturesForParticipants];
}

- (void)loadPicturesForParticipants {
    NSArray *participants = [GMDataSource sharedDataSource].currentCourse.participantsArray;
    
    for (GMParticipant *participant in participants) {
        NSString *url = [participant.imageURL absoluteString];
        // We only want to load the picture if (a) we have its URL and (b) it's not the default smiley candy icon
        if ([self.pictures objectForKey:url] == nil && ![url isEqualToString:@"https://gauchospace.ucsb.edu/courses/theme/gaucho/pix/u/f1.png"]) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:
             ^(NSURLResponse *response, NSData *data, NSError *error) {
                 /* Assuming we got data in response and can construct an image from it, add it to
                    the pictures dictionary */
                 if (data) {
                     UIImage *image = [UIImage imageWithData:data];
                     if (image) {
                         [self.pictures setObject:image forKey:url];
                         [presentationViewController reloadData];
                     }
                 }
            }];
        }
    }
}

#pragma mark -
#pragma mark Convenience methods

- (void)displayAddressBookEntryForParticipant:(GMParticipant *)participant {
    // Make sure we actually have a valid address book before attempting to look people up
    if (self.addressBook != NULL) {
        // Look up the person in question in the address book
        CFArrayRef matches = ABAddressBookCopyPeopleWithName(self.addressBook, (CFStringRef)participant.name);
        
        if (CFArrayGetCount(matches) != 0) {
            /* Assuming we found a match, initialize a GMOPersonViewController and set its person
               to the one we found earlier */
            GMOPersonViewController *controller = [[GMOPersonViewController alloc] init];
            controller.displayedPerson = CFArrayGetValueAtIndex(matches, 0);
            
            // On the iPhone, push the view controller...
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                [self.navigationController pushViewController:controller animated:YES];
            } else { //And on the iPad, present it modally as a sheet
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                navController.modalPresentationStyle = UIModalPresentationFormSheet;
                [self.navigationController presentModalViewController:navController animated:YES];
                [navController release];
            }
            
            [controller release];
        }
        
        CFRelease(matches);
    }
}

// This is just a convenience function to get the path for caching the dictionary of user images
- (NSString *)imageDictPath {
    // Find the Documents directory path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSInteger courseID = [GMDataSource sharedDataSource].currentCourse.courseID;
    // Assemble the filename based on the current course ID
    NSString *imageDictFilename = [NSString stringWithFormat:@"%ipics", courseID];
    // Then concatenate and return the result
    return [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:imageDictFilename];
}

// Sections is an array of every letter in the first name of a participant, used for the table view row headers
- (void)updateSections {
    NSDictionary *participants = [GMDataSource sharedDataSource].currentCourse.participants;
    NSArray *letters = [participants allKeys];
    self.sections = [letters sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

@end
