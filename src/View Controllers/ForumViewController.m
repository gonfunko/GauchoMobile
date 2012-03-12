//
//  ForumViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/7/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "ForumViewController.h"

@implementation ForumViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"Forums";
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    fetcher = [[GMSourceFetcher alloc] init];
    loadingView = [[GMLoadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, -25, 280, 27)];
    
    if ([[currentCourse forums] count] == 0) {
        [self loadForumsWithLoadingView:YES];
    }
    
    self.tableView.rowHeight = 80;
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.visibleViewController.navigationItem.title = @"Forums";
}

- (void)loadForumsWithLoadingView:(BOOL)flag {
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
        [fetcher forumsForCourse:currentCourse withDelegate:self];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading forums failed with error: %@", [error description]);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, -25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    loading = NO;
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, -25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
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
    [fetcher release];
    [loadingView removeFromSuperview];
    [super dealloc];
}

@end
