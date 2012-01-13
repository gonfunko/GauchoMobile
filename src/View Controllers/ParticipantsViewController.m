//
//  ParticipantsViewController.m
//  Handles presentation and interaction with the list of participants
//  Created by Group J5 for CS48
//

#import "ParticipantsViewController.h"


@implementation ParticipantsViewController

@synthesize tableView;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
    [photoRequests release];
    [sections release];
    [pictures release];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"Participants";
    
    photoRequests = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dictPath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%ipics.plist", (int)[[GMDataSource sharedDataSource] currentCourse].courseID]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dictPath])
        pictures = [[NSMutableDictionary dictionaryWithContentsOfFile:dictPath] retain];
    else
        pictures = [[NSMutableDictionary alloc] init];
    
    sections = [[NSMutableDictionary alloc] init];
    loadingView = [[GMLoadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, -25, 280, 27)];
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    fetcher = [[GMSourceFetcher alloc] init];
    
    if ([[currentCourse participants] count] == 0) {
        [self loadParticipantsWithLoadingView:YES];
    }
    
    if (reloadView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		reloadView = view;
		[view release];
	}
    
	[reloadView refreshLastUpdatedDate];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    NSArray *requests = [NSArray arrayWithArray:photoRequests];
    for (ASIHTTPRequest *request in requests) {
        [request clearDelegatesAndCancel];
    }
    
    //Based on http://stackoverflow.com/questions/2380173/iphone-how-to-write-an-image-to-disk-in-the-app-directories
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dictPath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%ipics.plist", (int)[[GMDataSource sharedDataSource] currentCourse].courseID]];
    [pictures writeToFile:dictPath atomically:YES];
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
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
                loadingView.frame = CGRectMake((int)(([[UIScreen mainScreen] bounds].size.height - 280) / 2), -25, 280, 27);
            else
                loadingView.frame = CGRectMake((int)(([[UIScreen mainScreen] bounds].size.width - 280) / 2), -25, 280, 27);
            
            loadingView.layer.zPosition = self.tableView.layer.zPosition + 1;
            [self.parentViewController.view addSubview:loadingView];
            [loadingView release];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, loadingView.layer.position.y + 25)];
            animation.duration = 0.25;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            [[loadingView layer] addAnimation:animation forKey:@"position"];
        }
        
        GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
        [fetcher participantsForCourse:currentCourse withDelegate:self];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading participants failed with error: %@", [error description]);
    
    loading = NO;
    [reloadView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, -25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    
    loading = NO;
    [reloadView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, -25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    
    GMParticipantsParser *parser = [[GMParticipantsParser alloc] init];
    NSArray *participants = [parser participantsFromSource:source];
    
    for (GMParticipant *participant in participants) {
        [[[GMDataSource sharedDataSource] currentCourse] addParticipant:participant];
    }
    
    [parser release];
    
    [self.tableView reloadData];
    
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
    
    //Based on http://stackoverflow.com/questions/2380173/iphone-how-to-write-an-image-to-disk-in-the-app-directories
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingFormat:@"/%@", [[[[request originalURL] absoluteString] substringFromIndex:8] stringByReplacingOccurrencesOfString:@"/" withString:@""]];
    [imageData writeToFile:path atomically:NO];
    [pictures setObject:path forKey:[[request originalURL] absoluteString]];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [photoRequests removeObject:request];
    NSError *error = [request error];
    NSLog(@"Downloading profile picture failed with error %@", [error description]);
}

- (void)loadPicturesForParticipants {
    NSArray *participants = [[[GMDataSource sharedDataSource] currentCourse] participants];
    for (GMParticipant *participant in participants) {
        NSString *url = [participant.imageURL absoluteString];
        if([pictures objectForKey:url] == nil) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
            [request setDelegate:self];
            [request startAsynchronous];
            [photoRequests addObject:request];
        }
    }
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *participants = [[[GMDataSource sharedDataSource] currentCourse] participants];
    
    int sectionsCount = 0;
    NSString *firstLetter = @"";
    for (int i = 0; i < [participants count]; i++) {
        if (![[[participants objectAtIndex:i] firstCharacterOfLastName] isEqualToString:firstLetter]) {
            sectionsCount++;
            firstLetter = [[participants objectAtIndex:i] firstCharacterOfLastName];
            [sections setObject:firstLetter forKey:[NSNumber numberWithInt:sectionsCount - 1]];
        }
    }
    
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *participants = [[[GMDataSource sharedDataSource] currentCourse] participants];
    
    NSString *firstLetter = [sections objectForKey:[NSNumber numberWithInteger:section]];
    int rows = 0;
    for (GMParticipant *participant in participants) {
        if ([[participant firstCharacterOfLastName] isEqualToString:firstLetter]) {
            rows++;
        }
    }
    
    return rows;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *participants = [[[GMDataSource sharedDataSource] currentCourse] participants];
    NSMutableArray *letters = [[NSMutableArray alloc] init];
    
    NSString *firstLetter = @"";
    for (int i = 0; i < [participants count]; i++) {
        if (![[[participants objectAtIndex:i] firstCharacterOfLastName] isEqualToString:firstLetter]) {
            firstLetter = [[participants objectAtIndex:i] firstCharacterOfLastName];
            [letters addObject:firstLetter];
        }
    }
    
    return [letters autorelease];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sections objectForKey:[NSNumber numberWithInteger:section]];
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
    
    NSArray *participants = [self participantsWithLastNameStartingWithLetter:[sections objectForKey:[NSNumber numberWithInteger:indexPath.section]]];
    GMParticipant *participant = [participants objectAtIndex:indexPath.row];
    
    cell.textLabel.text = participant.name;
    cell.detailTextLabel.text = participant.city;
    
    if([pictures objectForKey:[participant.imageURL absoluteString]] != nil) {
        cell.imageView.image = [UIImage imageWithContentsOfFile:[pictures objectForKey:[participant.imageURL absoluteString]]];
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
    NSArray *participants = [self participantsWithLastNameStartingWithLetter:[sections objectForKey:[NSNumber numberWithInteger:indexPath.section]]];
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
    NSArray *participants = [self participantsWithLastNameStartingWithLetter:[sections objectForKey:[NSNumber numberWithInteger:indexPath.section]]];
    GMParticipant *participant = [participants objectAtIndex:indexPath.row];

    [self displayAddressBookEntryForParticipant:participant];
    
    [table deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Convenience methods

- (NSArray *)participantsWithLastNameStartingWithLetter:(NSString *)letter {
    NSMutableArray *matchingParticipants = [NSMutableArray array];
    NSArray *participants = [[[GMDataSource sharedDataSource] currentCourse] participants];
    
    for (GMParticipant *participant in participants) {
        if ([[participant firstCharacterOfLastName] isEqualToString:letter]) {
            [matchingParticipants addObject:participant];
        }
    }
    
    return matchingParticipants;
}

- (void)displayAddressBookEntryForParticipant:(GMParticipant *)participant {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef matches = ABAddressBookCopyPeopleWithName(addressBook, (CFStringRef)participant.name);
    if (CFArrayGetCount(matches) != 0) {
        ABPersonViewController *controller = [[ABPersonViewController alloc] init];
        controller.displayedPerson = CFArrayGetValueAtIndex(matches, 0);
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    
    CFRelease(addressBook);
    CFRelease(matches);
}

#pragma mark - Reload view methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	
	[reloadView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	[reloadView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	
	[self loadParticipantsWithLoadingView:NO];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	
	return loading;
	
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	
	return [NSDate date];
}

@end

