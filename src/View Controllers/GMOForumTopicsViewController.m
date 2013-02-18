//
//  GMOForumTopicsViewController.m
//  GauchoMobile
//
//  GMOForumTopicsViewController is responsible for fetching and providing the list of topics in a
//  specific forum to a table view for presentation
//

#import "GMOForumTopicsViewController.h"

@interface GMOForumTopicsViewController ()

@property (retain) GMSourceFetcher *fetcher;

@end

@implementation GMOForumTopicsViewController

@synthesize forum;
@synthesize fetcher;

- (id)init {
    if (self = [super init]) {
        // Initialize the source fetcher
        fetcher = [[GMSourceFetcher alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up our table view
    self.tableView = [[GMOTableView alloc] init];
    
    // Configure the table view
    self.tableView.rowHeight = 49;
    ((GMOTableView *)self.tableView).placeholderLabel.text = @"No Topics";
    
    // Set the view controller title
    if (self.forum == nil) {
        self.title = @"Topics";
    } else {
        self.title = self.forum.title;
    }
    
    /* Listen to changes to the current course, and pop back to the root forum view controller
       if a different course is selected */
    [[NSNotificationCenter defaultCenter] addObserver:self.navigationController
                                             selector:@selector(popToRootViewControllerAnimated:)
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
    
    // Configure and add the pull to refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(loadTopics)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [refreshControl release];
    
    // If this forum doesn't have any topics, load them
    if ([self.forum.topics count] == 0) {
        [self loadTopics];
    }
}

// Allow rotation on the iPad and enforce portrait orientation on the iPhone
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)loadTopics {
    // Reload data immediately so we don't run into out of bounds issues
    [self.tableView reloadData];
    
    // Show the refresh control
    if (!self.refreshControl.isRefreshing) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
    }
    
    // Fetch the topics for our forum
    [self.fetcher topicsForForum:self.forum withDelegate:self];
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    // Present an alert with the error
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error loading topics"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    // Reload the table and stop the refresh control
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    // Create a parser and extract the topics from the source
    GMForumsParser *parser = [[GMForumsParser alloc] init];
    NSArray *topics = [parser forumTopicsFromSource:source];
    self.forum.topics = topics;
    
    [parser release];
    
    // Reload the table and stop the refresh control
    [self.tableView reloadData];
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
    // Dequeue a cell or load one from the xib
    GMForumTopicTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForumTopicTableCell"];
    if (cell == nil) {
        cell = [[[[NSBundle mainBundle] loadNibNamed:@"ForumTopicTableCell"
                                               owner:self
                                             options:nil] objectAtIndex:0] retain];
    }
    
    // Identify the topic corresponding to this row
    GMForumTopic *topic = [self.forum.topics objectAtIndex:indexPath.row];
    
    // Configure the cell
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
    // Deselect the chosen topic
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Create a GMOForumPostsViewController, set its topic to the one that was selected, and present it
    GMOForumPostsViewController *posts = [[GMOForumPostsViewController alloc] initWithNibName:@"ForumPostsViewController" bundle:[NSBundle mainBundle]];
    posts.topic = [self.forum.topics objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:posts animated:YES];
    [posts release];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.navigationController
                                                    name:@"GMCurrentCourseChangedNotification"
                                                  object:nil];
    [forum release];
    [fetcher release];
    [super dealloc];
}

@end
