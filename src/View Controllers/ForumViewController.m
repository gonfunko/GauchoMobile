//
//  ForumViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/7/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "ForumViewController.h"

@implementation ForumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadForums)
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(loadForums)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [refreshControl release];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"Forums";
    
    fetcher = [[GMSourceFetcher alloc] init];
    
    self.tableView.rowHeight = 80;
    
    noForumsLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    if ([[currentCourse forums] count] == 0) {
        [self loadForums];
    } else {
        [self.tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.visibleViewController.navigationItem.title = @"Forums";
    self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    noForumsLabel.frame = [self.tableView boundsForPlaceholderLabel];
}


- (void)loadForums {
    if (!self.refreshControl.isRefreshing) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
    }
        
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    [fetcher forumsForCourse:currentCourse withDelegate:self];
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading forums failed with error: %@", [error description]);
    
    [self.refreshControl endRefreshing];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    [[[GMDataSource sharedDataSource] currentCourse] removeAllForums];
    
    GMForumsParser *parser = [[GMForumsParser alloc] init];
    NSArray *forums = [parser forumsFromSource:source];
    
    for (GMForum *forum in forums) {
        [[[GMDataSource sharedDataSource] currentCourse] addForum:forum];
    }
    
    [parser release];
    
    [self.tableView reloadData];
    
    if ([forums count] == 0) {
        noForumsLabel = [[UITextField alloc] initWithFrame:[self.tableView boundsForPlaceholderLabel]];
        noForumsLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        noForumsLabel.enabled = NO;
        noForumsLabel.text = @"No Forums";
        noForumsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        noForumsLabel.textColor = [UIColor grayColor];
        noForumsLabel.textAlignment = UITextAlignmentCenter;
        [self.tableView addSubview:noForumsLabel];
        [noForumsLabel release];
    }
    
    [self.refreshControl endRefreshing];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rows = [[[[GMDataSource sharedDataSource] currentCourse] forums] count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GMForum *forum = [[[[GMDataSource sharedDataSource] currentCourse] forums] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = forum.title;
    cell.detailTextLabel.text = forum.forumDescription;
    cell.detailTextLabel.numberOfLines = 3;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ForumTopicsViewController *topics = [[ForumTopicsViewController alloc] initWithNibName:@"ForumTopicsViewController" bundle:[NSBundle mainBundle]];
    topics.forum = [[[[GMDataSource sharedDataSource] currentCourse] forums] objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:topics animated:YES];
    [topics release];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GMCurrentCourseChangedNotification" object:nil];
    [fetcher release];
    [super dealloc];
}

@end
