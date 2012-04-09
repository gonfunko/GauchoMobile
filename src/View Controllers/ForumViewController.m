//
//  ForumViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/7/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "ForumViewController.h"
#import "GMSplitViewController.h"

@implementation ForumViewController

@synthesize visible;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadForums)
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"Forums";
    
    fetcher = [[GMSourceFetcher alloc] init];
    
    self.tableView.rowHeight = 80;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.visible = YES;
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    if ([[currentCourse forums] count] == 0) {
        [self loadForumsWithLoadingView:YES];
    } else {
        [self.tableView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.visible = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.visibleViewController.navigationItem.title = @"Forums";
    self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillLayoutSubviews
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.navigationController.topViewController.navigationItem.leftBarButtonItem = ((GMSplitViewController *)[self splitViewController]).barButtonItem;
        } else {
            self.navigationController.topViewController.navigationItem.leftBarButtonItem = nil;
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)loadForums {
    if (self.visible) {
        [self loadForumsWithLoadingView:YES];
    }
}

- (void)loadForumsWithLoadingView:(BOOL)flag {
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
        [fetcher forumsForCourse:currentCourse withDelegate:self];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading forums failed with error: %@", [error description]);
    
    [HUD hide:YES];
    loading = NO;
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    [HUD hide:YES];
    loading = NO;
    
    [[[GMDataSource sharedDataSource] currentCourse] removeAllForums];
    
    GMForumsParser *parser = [[GMForumsParser alloc] init];
    NSArray *forums = [parser forumsFromSource:source];
    
    for (GMForum *forum in forums) {
        [[[GMDataSource sharedDataSource] currentCourse] addForum:forum];
    }
    
    [parser release];
    
    [self.tableView reloadData];
    
    if ([forums count] == 0) {
        UITextField *label = [[UITextField alloc] initWithFrame:CGRectMake(0, (self.tableView.frame.size.height - 30) / 2 - 25, self.tableView.frame.size.width, 30)];
        label.enabled = NO;
        label.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        label.text = @"No Forums";
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentCenter;
        [self.tableView addSubview:label];
        [label release];
    }
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
