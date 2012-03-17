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
    [reloadView removeFromSuperview];
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
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    fetcher = [[GMSourceFetcher alloc] init];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [HUD hide:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadDashboard) 
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
     
     if (reloadView == nil) {
         EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
         view.delegate = self;
         [self.tableView addSubview:view];
         reloadView = view;
         [view release];
     }
     
     [reloadView refreshLastUpdatedDate];
    
    if (currentCourse != nil && [[currentCourse dashboardItems] count] == 0) {
        [self loadDashboardWithLoadingView:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
     [self loadDashboardWithLoadingView:YES];
 }

- (void)loadDashboardWithLoadingView:(BOOL)flag {
    if (!loading) {
        loading = YES;
    
        if (flag) {
            HUD.labelText = @"Loading";
            [HUD show:YES];
        }
        
        GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
        [fetcher dashboardForCourse:currentCourse withDelegate:self];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading dashboard failed with error: %@", [error description]);
    
    loading = NO;
    [HUD hide:YES];
    [reloadView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    
    loading = NO;
    [HUD hide:YES];
    [reloadView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
       
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
    return [[[[[GMDataSource sharedDataSource] currentCourse] dashboardItems] objectAtIndex:section] dateRange];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        GMDashboardItem *item = [[[[GMDataSource sharedDataSource] currentCourse] dashboardItems] objectAtIndex:indexPath.section];
        //Based on http://stackoverflow.com/questions/2669063/how-to-get-the-size-of-a-nsstring
        CGSize maximumSize = CGSizeMake(300, 9999);
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
        CGSize maximumSize = CGSizeMake(300, 9999);
        CGSize stringSize = [item.contents sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16.0] 
                                      constrainedToSize:maximumSize 
                                          lineBreakMode:UILineBreakModeWordWrap];
        CGRect textViewFrame = ((GMTextViewTableCell *)cell).textView.frame;
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

#pragma mark - Reload view methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	
	[reloadView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	[reloadView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	
	[self loadDashboardWithLoadingView:NO];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
	
	return loading;
	
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
	
	return [NSDate date];
}

@end
