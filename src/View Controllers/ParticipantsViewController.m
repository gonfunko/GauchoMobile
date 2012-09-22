//
//  ParticipantsViewController.m
//  Handles presentation and interaction with the list of participants
//  Created by Group J5 for CS48
//

#import "ParticipantsViewController.h"


@implementation ParticipantsViewController

@synthesize tableView;
@synthesize sections;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    self.sections = nil;
    [photoRequests release];
    [pictures release];
    [fetcher release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"People";
    
    photoRequests = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dictPath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%ipics", (int)[[GMDataSource sharedDataSource] currentCourse].courseID]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dictPath]) {
        pictures = [[NSKeyedUnarchiver unarchiveObjectWithFile:dictPath] retain];
    }
    else
        pictures = [[NSMutableDictionary alloc] init];
    
    self.sections = [NSMutableArray array];
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    fetcher = [[GMSourceFetcher alloc] init];
    
    if ([[currentCourse participants] count] == 0) {
        [self loadParticipantsWithLoadingView:YES];
    } else {
        NSDictionary *_participants = [[[GMDataSource sharedDataSource] currentCourse] participants];
        NSArray *letters = [_participants allKeys];
        self.sections = [letters sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    NSArray *requests = [NSArray arrayWithArray:photoRequests];
    for (ASIHTTPRequest *request in requests) {
        [request clearDelegatesAndCancel];
    }
    
    //Based on http://stackoverflow.com/questions/2380173/iphone-how-to-write-an-image-to-disk-in-the-app-directories
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dictPath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%ipics", (int)[[GMDataSource sharedDataSource] currentCourse].courseID]];
    NSData *picsData = [NSKeyedArchiver archivedDataWithRootObject:pictures];
    [picsData writeToFile:dictPath atomically:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.visibleViewController.navigationItem.title = @"Participants";
    self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidUnload {
    
}

#pragma mark - Data loading methods

- (void)loadParticipantsWithLoadingView:(BOOL)flag {
    if (!loading) {
        loading = YES;
        
        if (flag) {
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            [HUD release];
            HUD.labelText = @"Loading";
            HUD.removeFromSuperViewOnHide = YES;
            [HUD show:YES];
        }
        
        GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
        [fetcher participantsForCourse:currentCourse withDelegate:self];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading participants failed with error: %@", [error description]);
    
    loading = NO;
    [HUD hide:YES];
    HUD = nil;
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    
    loading = NO;
    if (HUD != nil) {
        [HUD hide:YES];
        HUD = nil;
    }
    
    GMParticipantsParser *parser = [[GMParticipantsParser alloc] init];
    NSArray *participants = [parser participantsFromSource:source];
    [[GMDataSource sharedDataSource] currentCourse].participantsArray = [NSArray array];
    
    for (GMParticipant *participant in participants) {
        [[[GMDataSource sharedDataSource] currentCourse] addParticipant:participant];
    }
    
    [parser release];
    
    NSDictionary *_participants = [[[GMDataSource sharedDataSource] currentCourse] participants];
    NSArray *letters = [_participants allKeys];
    self.sections = [letters sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [self.tableView reloadData];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dictPath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%ipics", (int)[[GMDataSource sharedDataSource] currentCourse].courseID]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dictPath]) {
        [pictures release];
        pictures = [[NSKeyedUnarchiver unarchiveObjectWithFile:dictPath] retain];
    }
    else {
        [pictures release];
        pictures = [[NSMutableDictionary alloc] init];
    }
    
    [self loadPicturesForParticipants];
    
    if ([participants count] == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.tableView.frame.size.height - 30) / 2, self.tableView.frame.size.width, 30)];
        label.text = @"No Participants";
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentCenter;
        [self.tableView addSubview:label];
        [label release];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [photoRequests removeObject:request];
    NSData *imageData = [request responseData];
    UIImage *pic = [UIImage imageWithData:imageData];
    [pictures setObject:pic forKey:[[request originalURL] absoluteString]];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [photoRequests removeObject:request];
    NSError *error = [request error];
    NSLog(@"Downloading profile picture failed with error %@", [error description]);
}

- (void)loadPicturesForParticipants {
    NSDictionary *participants = [[[GMDataSource sharedDataSource] currentCourse] participants];
    NSMutableArray *allParticipants = [[NSMutableArray alloc] init];
    for (NSString *key in [participants allKeys]) {
        [allParticipants addObjectsFromArray:[participants objectForKey:key]];
    }
    
    for (GMParticipant *participant in allParticipants) {
        NSString *url = [participant.imageURL absoluteString];
        if([pictures objectForKey:url] == nil && ![url isEqualToString:@"https://gauchospace.ucsb.edu/courses/theme/gaucho/pix/u/f1.png"]) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
            [request setDelegate:self];
            [request startAsynchronous];
            [photoRequests addObject:request];
        }
    }
    
    [allParticipants release];
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int total = [[[[[GMDataSource sharedDataSource] currentCourse] participants] allKeys] count] - 1;
    return MAX(total, 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *participants = [[[GMDataSource sharedDataSource] currentCourse] participants];
    NSString *firstLetter = [sections objectAtIndex:section];
    
    if ([participants objectForKey:firstLetter] != nil) {
        return [[participants objectForKey:firstLetter] count];
    } else {
        return 0;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray *participants = [[[[GMDataSource sharedDataSource] currentCourse] participants] objectForKey:[sections objectAtIndex:indexPath.section]];
    GMParticipant *participant = [participants objectAtIndex:indexPath.row];
    
    cell.textLabel.text = participant.name;
    cell.detailTextLabel.text = participant.city;
    
    if([pictures objectForKey:[participant.imageURL absoluteString]] != nil) {
        cell.imageView.image = [pictures objectForKey:[participant.imageURL absoluteString]];
     }
     else {
         cell.imageView.image = [UIImage imageNamed:@"defaulticon.png"];
     }
    
    if (participant.inAddressBook) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *participants = [[[[GMDataSource sharedDataSource] currentCourse] participants] objectForKey:[sections objectAtIndex:indexPath.section]];
    GMParticipant *participant = [participants objectAtIndex:indexPath.row];
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef matches = ABAddressBookCopyPeopleWithName(addressBook, (CFStringRef)participant.name);
    CFRelease(addressBook);
    if (CFArrayGetCount(matches) != 0) {
        CFRelease(matches);
        return indexPath;
    }
    
    CFRelease(matches);
    
    return nil;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *participants = [[[[GMDataSource sharedDataSource] currentCourse] participants] objectForKey:[sections objectAtIndex:indexPath.section]];
    GMParticipant *participant = [participants objectAtIndex:indexPath.row];
    
    [self displayAddressBookEntryForParticipant:participant];
    
    [table deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Convenience methods

- (void)displayAddressBookEntryForParticipant:(GMParticipant *)participant {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef matches = ABAddressBookCopyPeopleWithName(addressBook, (CFStringRef)participant.name);
    if (CFArrayGetCount(matches) != 0) {
        ABPersonViewController *controller = [[GMPersonViewController alloc] init];
        controller.displayedPerson = CFArrayGetValueAtIndex(matches, 0);
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController presentModalViewController:navController animated:YES];
            [navController release];
        }
        [controller release];
    }
    
    CFRelease(addressBook);
    CFRelease(matches);
}

@end

