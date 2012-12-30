//
//  ForumPostsViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/11/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "ForumPostsViewController.h"

@implementation ForumPostsViewController

@synthesize topic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.topic = nil;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"M/d/y h:mm a"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        pictures = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    if (self.topic == nil) {
        self.navigationController.visibleViewController.navigationItem.title = @"Messages";
    } else {
        self.navigationController.visibleViewController.navigationItem.title = topic.title;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self.navigationController
                                             selector:@selector(popToRootViewControllerAnimated:)
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
    
    fetcher = [[GMSourceFetcher alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(loadPosts)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [refreshControl release];
    
    if ([topic.posts count] == 0) {
        [self loadPosts];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)loadPosts {
    if (!self.refreshControl.isRefreshing) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
    }
    
    [fetcher postsForTopic:self.topic withDelegate:self];
}

- (void)loadPictures {
    NSMutableArray *allParticipants = [[NSMutableArray alloc] init];
    
    for (GMForumPost *post in self.topic.posts) {
        [allParticipants addObject:post.author];
    }
    
    for (GMParticipant *participant in allParticipants) {
        NSString *url = [participant.imageURL absoluteString];
        if (![url isEqualToString:@"https://gauchospace.ucsb.edu/courses/theme/gaucho/pix/u/f1.png"]) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if (data) {
                    UIImage *photo = [UIImage imageWithData:data];
                    //It's possible (if we have a bad URL) that we could get a valid response that isn't image data. Hence, we need to check we actually have an image.
                    if (photo) {
                        [pictures setObject:photo forKey:url];
                        [self.tableView reloadData];
                    }
                }
            }];
        }
    }
    
    [allParticipants release];
}


- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading forum posts failed with error: %@", [error description]);
    [self.refreshControl endRefreshing];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {    
    GMForumsParser *parser = [[GMForumsParser alloc] init];
    NSArray *posts = [parser forumPostsFromSource:source];  
    topic.posts = posts;
    
    [parser release];
    
    [self.tableView reloadData];
    
    [self loadPictures];
    
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.topic.posts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMForumPostTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForumPostTableCell"];
    if (cell == nil) {
        cell = [[[[NSBundle mainBundle] loadNibNamed:@"ForumPostTableCell" owner:self options:nil] objectAtIndex:0] retain];
    }
    
    GMForumPost *post = [self.topic.posts objectAtIndex:indexPath.section];
    
    cell.name.text = post.author.name;
    cell.date.text = [NSString stringWithFormat:@"Posted %@", [formatter stringFromDate:post.postDate]];
    if ([pictures objectForKey:[post.author.imageURL absoluteString]] == nil) {
        cell.userPhoto.image = [UIImage imageNamed:@"defaulticon.png"];
    } else {
        cell.userPhoto.image = [pictures objectForKey:[post.author.imageURL absoluteString]];
    }
    cell.post.text = post.message;
    
    return [cell autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GMForumPost *post = [self.topic.posts objectAtIndex:indexPath.section];
    CGSize size = [post.message sizeWithFont:[UIFont systemFontOfSize:14]
                           constrainedToSize:CGSizeMake(tableView.frame.size.width - 40, 1900)
                               lineBreakMode:UILineBreakModeWordWrap];
    
    return size.height + 60 + 10;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.layer.masksToBounds = YES;
    cell.contentView.layer.cornerRadius = 9.0f;
    cell.contentView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    cell.contentView.layer.shouldRasterize = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.navigationController name:@"GMCurrentCourseChangedNotification" object:nil];
    self.topic = nil;
    [fetcher release];
    [formatter release];
    [pictures release];
    [super dealloc];
}

@end
