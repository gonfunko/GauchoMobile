//
//  GMPeopleViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 12/31/12.
//
//

#import "GMPeopleViewController.h"

@interface GMPeopleViewController ()

@property (retain) NSMutableDictionary *pictures;
@property (retain) GMSourceFetcher *fetcher;
@property (assign) ABAddressBookRef addressBook;

@end

@implementation GMPeopleViewController

@synthesize pictures;
@synthesize fetcher;
@synthesize addressBook;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imageDictPath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%ipics", (NSInteger)[[GMDataSource sharedDataSource] currentCourse].courseID]];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageDictPath]) {
            self.pictures = [NSKeyedUnarchiver unarchiveObjectWithFile:imageDictPath];
        } else {
            self.pictures = [NSMutableDictionary dictionary];
        }

        
        GMSourceFetcher *sourceFetcher = [[GMSourceFetcher alloc] init];
        self.fetcher = sourceFetcher;
        [sourceFetcher release];
        
        self.addressBook = ABAddressBookCreate();
        #warning check if block can be nil
        ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {});
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.visibleViewController.navigationItem.title = @"People";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    
    if ([[currentCourse participants] count] == 0) {
        [self loadParticipants];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Based on http://stackoverflow.com/questions/2380173/iphone-how-to-write-an-image-to-disk-in-the-app-directories
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imageDictPath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%ipics", (NSInteger)[[GMDataSource sharedDataSource] currentCourse].courseID]];
    NSData *picsData = [NSKeyedArchiver archivedDataWithRootObject:self.pictures];
    [picsData writeToFile:imageDictPath atomically:YES];
}

- (void)loadParticipants {
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    [fetcher participantsForCourse:currentCourse withDelegate:self];
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading participants failed with error: %@", [error description]);
    
    [self.refreshControl endRefreshing];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
