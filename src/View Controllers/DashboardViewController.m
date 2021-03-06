//
//  DashboardViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DashboardViewController.h"


@implementation DashboardViewController

- (void)dealloc
{
    [fetcher release];
    [dateFormatter release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GMLoginSuccessfulNotification" object:nil];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"Dashboard";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(loadDashboard)
             forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    [refreshControl release];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    fetcher = [[GMSourceFetcher alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadDashboard) 
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDashboard)
                                                 name:@"GMLoginSuccessfulNotification"
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    if (currentCourse != nil && [[currentCourse dashboardItems] count] == 0) {
        [self loadDashboard];
    } else {
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.visibleViewController.navigationItem.title = @"Dashboard";
    self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark - Data loading methods

- (void)loadDashboard {
    if (!self.refreshControl.isRefreshing) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
    }
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    [fetcher dashboardForCourse:currentCourse withDelegate:self];
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading dashboard failed with error: %@", [error description]);
    
    [self.refreshControl endRefreshing];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    GMDashboardParser *parser = [[GMDashboardParser alloc] init];
    NSArray *items = [parser dashboardItemsFromSource:source];
    
    for (GMDashboardItem *item in items) {
        [[[GMDataSource sharedDataSource] currentCourse] addDashboardItem:item];
    }
    
    [parser release];
    
    [self.tableView reloadData];
    
    if ([items count] == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.tableView.frame.size.height - 30) / 2, self.tableView.frame.size.width, 30)];
        label.text = @"No Dashboard Items";
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentCenter;
        [self.tableView addSubview:label];
        [label release];
    }
    
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[[GMDataSource sharedDataSource] currentCourse] dashboardItems] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[[[GMDataSource sharedDataSource] currentCourse] dashboardItems] objectAtIndex:section] links] count] + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = [[[[[GMDataSource sharedDataSource] currentCourse] dashboardItems] objectAtIndex:section] dateRange];
    if ([title isEqualToString:@""]) {
        title = @"Course Info";
    }
    
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        GMDashboardItem *item = [[[[GMDataSource sharedDataSource] currentCourse] dashboardItems] objectAtIndex:indexPath.section];
        //Based on http://stackoverflow.com/questions/2669063/how-to-get-the-size-of-a-nsstring
        CGSize maximumSize;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            maximumSize = CGSizeMake(300, 9999);
        } else {
            maximumSize = CGSizeMake(self.tableView.bounds.size.width - 20, 9999);
        }
        
        CGSize stringSize = [item.contents sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16.0] 
                                   constrainedToSize:maximumSize 
                                       lineBreakMode:UILineBreakModeWordWrap];
        return stringSize.height + 15;
    } else {
        return tableView.rowHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMDashboardItem *item = [[[[GMDataSource sharedDataSource] currentCourse] dashboardItems] objectAtIndex:indexPath.section];
    
    UITableViewCell *cell = nil;
    if (indexPath.row == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:@"text"];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"link"];
    
    if (cell == nil) {
        if (indexPath.row == 0)
            cell = [[[GMTextViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"text"] autorelease];
        else
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"link"] autorelease];
    }
    
    if (indexPath.row == 0) {
        ((GMTextViewTableCell *)cell).textView.text = item.contents;
        CGRect textViewFrame = ((GMTextViewTableCell *)cell).textView.frame;
        CGSize maximumSize;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            maximumSize = CGSizeMake(300, 9999);
        } else {
            maximumSize = CGSizeMake(self.tableView.bounds.size.width - 20, 9999);
        }
        
        CGSize stringSize = [item.contents sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16.0] 
                                      constrainedToSize:maximumSize 
                                          lineBreakMode:UILineBreakModeWordWrap];
        
        ((GMTextViewTableCell *)cell).textView.frame = CGRectMake(textViewFrame.origin.x, textViewFrame.origin.y, textViewFrame.size.width, stringSize.height + 10);
    } else {
        cell.textLabel.text = [[[item links] objectAtIndex:indexPath.row - 1] objectForKey:@"title"];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return nil;
    } else {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMDashboardItem *item = [[[[GMDataSource sharedDataSource] currentCourse] dashboardItems] objectAtIndex:indexPath.section];
    NSURL *url = [NSURL URLWithString:[[[item links] objectAtIndex:indexPath.row - 1] objectForKey:@"url"]];
    WebViewController *controller = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]];
    [controller loadURL:url];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([self currentDateWithinDateRangeString:[self tableView:tableView titleForHeaderInSection:section]]) {
        UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 23)] autorelease];
        CALayer *yellowHeader = [[CALayer alloc] init];
        yellowHeader.frame = CGRectMake(0, -1, tableView.bounds.size.width, 23);
        yellowHeader.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"currentweeksectionheader"]].CGColor;
        [headerView.layer addSublayer:yellowHeader];
        [yellowHeader release];
        
        UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, -1, tableView.bounds.size.width - 24, 23)];
        sectionLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        sectionLabel.textColor = [UIColor whiteColor];
        sectionLabel.font = [UIFont boldSystemFontOfSize:18.0];
        sectionLabel.backgroundColor = [UIColor clearColor];
        sectionLabel.shadowColor = [UIColor colorWithRed:0.617 green:0.496 blue:0.000 alpha:1.000];
        sectionLabel.shadowOffset = CGSizeMake(0, 1);
        [headerView addSubview:sectionLabel];
        [sectionLabel release];
        
        return headerView;
    } else {
        return nil;
    }
}

- (BOOL)currentDateWithinDateRangeString:(NSString *)range {
    if (range && ![range isEqualToString:@"Course Info"]) {
        NSDate *now = [NSDate date];
        [dateFormatter setDateFormat:@"dd MMMM"];
        NSString *startDateString = [range substringToIndex:[range rangeOfString:@" - "].location];
        NSString *endDateString = [range substringFromIndex:[range rangeOfString:@" - "].location + 3];
        NSDate *startDate = [dateFormatter dateFromString:startDateString];
        NSDate *endDate = [dateFormatter dateFromString:endDateString];
        
        NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit fromDate:now];
        NSString *nowString = [NSString stringWithFormat:@"%d %d", nowComponents.day, nowComponents.month];
        [dateFormatter setDateFormat:@"dd MM"];
        now = [dateFormatter dateFromString:nowString];
        
        if (([now compare:startDate] == NSOrderedSame || [now compare:startDate] == NSOrderedDescending) &&
            ([now compare:endDate] == NSOrderedSame || [now compare:endDate] == NSOrderedAscending)) {
            return YES;
        }
    }
    
    return NO;
}

@end
