//
//  ForumTopicsViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/11/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "ForumTopicsViewController.h"

@implementation ForumTopicsViewController

@synthesize forum;
@synthesize topicCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.forum = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    if (self.forum == nil) {
        self.navigationController.visibleViewController.navigationItem.title = @"Topics";
    } else {
        self.navigationController.visibleViewController.navigationItem.title = forum.title;
    }
    
    fetcher = [[GMSourceFetcher alloc] init];
    loadingView = [[GMLoadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, -25, 280, 27)];
    
    if ([forum.topics count] == 0) {
        [self loadTopicsWithLoadingView:YES];
    }
    
    self.tableView.rowHeight = 49;
}

- (void)loadTopicsWithLoadingView:(BOOL)flag {
    if (!loading) {
        loading = YES;
        
        if (flag) {
            loadingView.hidden = NO;
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
                loadingView.frame = CGRectMake((int)(([[UIScreen mainScreen] bounds].size.height - 280) / 2), -25, 280, 27);
            else
                loadingView.frame = CGRectMake((int)(([[UIScreen mainScreen] bounds].size.width - 280) / 2), -25, 280, 27);
            
            loadingView.layer.zPosition = self.tableView.layer.zPosition + 1;
            
            [self.tableView addSubview:loadingView];
            self.tableView.scrollEnabled = NO;
            [loadingView release];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, loadingView.layer.position.y + 25)];
            animation.duration = 0.25;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            [[loadingView layer] addAnimation:animation forKey:@"position"];
        }
        
        [fetcher topicsForForum:forum withDelegate:self];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading forum topics failed with error: %@", [error description]);

    self.tableView.scrollEnabled = YES;
    loadingView.hidden = YES;
    
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

    self.tableView.scrollEnabled = YES;
    loadingView.hidden = YES;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, -25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    loading = NO;
    
    GMForumsParser *parser = [[GMForumsParser alloc] init];
    NSArray *forums = [parser forumTopicsFromSource:source];
    forum.topics = forums;
    
    [parser release];
    
    [self.tableView reloadData];
    
    if ([forums count] == 0) {
        UITextField *label = [[UITextField alloc] initWithFrame:CGRectMake(0, (self.tableView.frame.size.height - 30) / 2 - 35, self.tableView.frame.size.width, 30)];
        label.enabled = NO;
        label.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        label.text = @"No Topics";
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentCenter;
        [self.tableView addSubview:label];
        [label release];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.forum.topics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ForumTopicTableCell";
    GMForumTopicTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ForumTopicTableCell" owner:self options:nil];
        cell = topicCell;
    }
    
    GMForumTopic *topic = [self.forum.topics objectAtIndex:indexPath.row];
    
    cell.title.text = topic.title;
    cell.author.text = [NSString stringWithFormat:@"Started by %@", topic.author.name];
    cell.replies.titleLabel.text = [NSString stringWithFormat:@"%i", topic.replies];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ForumPostsViewController *posts = [[ForumPostsViewController alloc] initWithNibName:@"ForumPostsViewController" bundle:[NSBundle mainBundle]];
    posts.topic = [self.forum.topics objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:posts animated:YES];
    [posts release];
}


- (void)dealloc {
    NSLog(@"topics dealloc");
    self.forum = nil;
    [fetcher release];
    [loadingView removeFromSuperview];
    [super dealloc];
}

@end
