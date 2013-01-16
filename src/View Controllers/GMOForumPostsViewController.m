//
//  GMOForumPostsViewController.h
//  GauchoMobile
//
//  GMOForumPostsViewController is responsible for fetching and providing the list of posts in a
//  specific forum topic to a table view for presentation
//

#import "GMOForumPostsViewController.h"

@interface GMOForumPostsViewController () {
    GMSourceFetcher *fetcher;
    NSDateFormatter *formatter;
    NSMutableDictionary *pictures;
}

@end

@implementation GMOForumPostsViewController

@synthesize topic;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Initialize our topic to nil
        self.topic = nil;
        
        /* Create and configure a date formatter to be used when formatting times for display
           This is done once here because NSDateFormatters have notoriously high overhead, so we don't
           want to make one every time the table requests a cell */
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"M/d/y h:mm a"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        // Initialize the pictures dictionary
        pictures = [[NSMutableDictionary alloc] init];
        
        // Initialize the source fetcher
        fetcher = [[GMSourceFetcher alloc] init];
    }
    return self;
}

#pragma mark - View lifecycle/delegate

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure and add the pull-to-refresh control
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // If we don't have a topic, set the nav bar title to Messages; otherwise set it to the topic's title
    if (self.topic == nil) {
        self.navigationItem.title = @"Messages";
    } else {
        self.navigationController.visibleViewController.navigationItem.title = topic.title;
    }
    
    // Add ourself as an observer on the current course so we can dismiss ourself when it changes
    [[GMDataSource sharedDataSource] addObserver:self
                                      forKeyPath:@"currentCourse"
                                         options:NSKeyValueObservingOptionNew
                                         context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Remove ourself as an observer on the current course when our view disappears
    [[GMDataSource sharedDataSource] removeObserver:self forKeyPath:@"currentCourse"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    /* This is the only notification we're observing, 
       but be defensive about it since we dismiss ourself when we observe it */
    if ([keyPath isEqualToString:@"currentCourse"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Data loading

- (void)loadPosts {
    // Show and start the refresh indicator
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    
    // Load the posts for our topic
    [fetcher postsForTopic:self.topic withDelegate:self];
}

- (void)loadPictures {
    NSMutableArray *allParticipants = [[NSMutableArray alloc] init];
    
    // Identify all the authors of posts in this topic
    for (GMForumPost *post in self.topic.posts) {
        [allParticipants addObject:post.author];
    }
    
    // Assuming their profile picture is not the default, load it from the network
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
    [self.refreshControl endRefreshing];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error loading posts"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    // Create a forum parser
    GMForumsParser *parser = [[GMForumsParser alloc] init];
    // And extract the posts from the page source we received
    NSArray *posts = [parser forumPostsFromSource:source];
    
    // Update our topic's posts
    topic.posts = posts;
    
    [parser release];
    
    // Display the posts in the table
    [self.tableView reloadData];
    
    // Fetch author profile pictures
    [self loadPictures];
    
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    /* To get the nice rounded corner effect, each post lives in its own section, hence why this is
       returned here and not in numberOfRowsInSection: */
    return [self.topic.posts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Each section has one post, always. See above comment in numberOfSectionsInTableView:
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get a GMOForumPostTableCell, either by reusing one or loading one from the xib
    GMForumPostTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForumPostTableCell"];
    if (cell == nil) {
        cell = [[[[NSBundle mainBundle] loadNibNamed:@"ForumPostTableCell" owner:self options:nil] objectAtIndex:0] retain];
    }
    
    /* Identify the post corresponding to this table view row
       Note that we're accessing the section of the indexPath because each post has its own section */
    GMForumPost *post = [self.topic.posts objectAtIndex:indexPath.section];
    
    // Configure the cell with the post's information
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
    // Identify the post diplayed in this row
    GMForumPost *post = [self.topic.posts objectAtIndex:indexPath.section];
    // Determine the bounds of its text when drawn on screen
    CGSize size = [post.message sizeWithFont:[UIFont systemFontOfSize:14]
                           constrainedToSize:CGSizeMake(tableView.frame.size.width - 40, 1900)
                               lineBreakMode:UILineBreakModeWordWrap];
    
    // Return the size of the text plus 60 points for the post header plus 10 points of footer spacing
    return size.height + 60 + 10;
}

/* For whatever reason, the rounded corners on UITableView sections don't automatically mask their content.
   Thus, before each cell is displayed, we do so manually so there aren't pointy bits extending beyond the
   nice rounded corners */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.layer.masksToBounds = YES;
    cell.contentView.layer.cornerRadius = 9.0f;
    cell.contentView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    cell.contentView.layer.shouldRasterize = YES;
}

#pragma mark - Cleanup

- (void)dealloc {
    self.topic = nil;
    [fetcher release];
    [formatter release];
    [pictures release];
    [super dealloc];
}

@end
