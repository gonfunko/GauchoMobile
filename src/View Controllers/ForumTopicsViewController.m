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
    
    [[NSNotificationCenter defaultCenter] addObserver:self.navigationController
                                             selector:@selector(popToRootViewControllerAnimated:)
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(loadTopics)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [refreshControl release];
    
    fetcher = [[GMSourceFetcher alloc] init];
    
    if ([forum.topics count] == 0) {
        [self loadTopics];
    }
    
    self.tableView.rowHeight = 49;
    
    noTopicsLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    noTopicsLabel.frame = [self.tableView boundsForPlaceholderLabel];
}

- (void)loadTopics {
    if (!self.refreshControl.isRefreshing) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
    }
        
    [fetcher topicsForForum:forum withDelegate:self];
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading forum topics failed with error: %@", [error description]);

    [self.refreshControl endRefreshing];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    GMForumsParser *parser = [[GMForumsParser alloc] init];
    NSArray *forums = [parser forumTopicsFromSource:source];
    forum.topics = forums;
    
    [parser release];
    
    [self.tableView reloadData];
    
    if ([forums count] == 0) {
        noTopicsLabel = [[UITextField alloc] initWithFrame:[self.tableView boundsForPlaceholderLabel]];
        noTopicsLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        noTopicsLabel.enabled = NO;
        noTopicsLabel.text = @"No Topics";
        noTopicsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        noTopicsLabel.textColor = [UIColor grayColor];
        noTopicsLabel.textAlignment = UITextAlignmentCenter;
        noTopicsLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.tableView addSubview:noTopicsLabel];
        [noTopicsLabel release];
    }
    
    [self.refreshControl endRefreshing];
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
    [cell.replies setTitle:[NSString stringWithFormat:@"%i", topic.replies]
                  forState:UIControlStateDisabled];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self.navigationController name:@"GMCurrentCourseChangedNotification" object:nil];
    self.forum = nil;
    [fetcher release];
    [super dealloc];
}

@end
