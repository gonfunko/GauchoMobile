//
//  GMOParticipantsViewController.m
//  GauchoMobile
//
//  GMParticipantsTableViewController is responsible for providing data, configuring cells and
//  managing selections for the list of participants in a course
//

#import "GMParticipantsTableViewController.h"

@interface GMParticipantsTableViewController () {
    /* This isn't strictly necessary, since UIViewController already has the parentViewController
       property. However, by declaring it as an instance of GMOParticipantsViewController, we can avoid
       using a cast everywhere we reference our parent view controller */
    GMOParticipantsViewController *parent;
}

@end


@implementation GMParticipantsTableViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:parent
                       action:@selector(loadParticipants)
              forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [refreshControl release];
    
    // Configure the placeholder label displayed when there are no participants
    ((GMOTableView *)self.tableView).placeholderLabel.text = @"No People";
}

// We explicitly set the value of parent when it is passed to us, since self.parentViewController is nil in viewDidLoad
- (void)didMoveToParentViewController:(UIViewController *)parentVC {
    [super didMoveToParentViewController:parentVC];
    parent = (GMOParticipantsViewController *)parentVC;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark GMParticipantsChildViewController protocol implementation

/* These methods are called when our parent view controller starts loading data, finishes loading
   data and when we need to re-fetch data from the parent, respectively. */

- (void)loadingStarted {
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
}

- (void)loadingFinished {
    [self.refreshControl endRefreshing];
}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [parent.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *participants = [GMDataSource sharedDataSource].currentCourse.participants;

    // parent.sections is an array of letters, corresponding to all the first letters in the names of the participants
    NSString *firstLetter = [parent.sections objectAtIndex:section];
    
    /* If the participants dictionary (which maps letters to arrays of participants whose name starts with that letter)
       has this letter, return the number of participants in the corresponding array */
    if ([participants objectForKey:firstLetter] != nil) {
        return [[participants objectForKey:firstLetter] count];
    }
    
    return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return parent.sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [parent.sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ParticipantsCell";
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
    // Look up the array of participants whose first letter of their name corresponds to the letter at the current section index
    NSArray *participants = [[GMDataSource sharedDataSource].currentCourse.participants objectForKey:[parent.sections objectAtIndex:indexPath.section]];
    // And find the particular one we're after
    GMParticipant *participant = [participants objectAtIndex:indexPath.row];
    
    cell.textLabel.text = participant.name;
    cell.detailTextLabel.text = participant.city;
    
    // If we don't have an image in the cache, just use the default smiley candy one
    if ([parent.pictures objectForKey:[participant.imageURL absoluteString]] != nil) {
        cell.imageView.image = [parent.pictures objectForKey:[participant.imageURL absoluteString]];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"defaulticon.png"];
    }
    
    // If this person is in our contacts, add a disclosure indicator to show their contact card
    if (participant.inAddressBook) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *participants = [[[[GMDataSource sharedDataSource] currentCourse] participants] objectForKey:[parent.sections objectAtIndex:indexPath.section]];
    GMParticipant *participant = [participants objectAtIndex:indexPath.row];
    
    // If the person at this row is in the address book, allow them to be selected
    if (participant.inAddressBook) {
        return indexPath;
    } else { // Otherwise, return nil to disallow the selection
        return nil;
    }
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *participants = [[[[GMDataSource sharedDataSource] currentCourse] participants] objectForKey:[parent.sections objectAtIndex:indexPath.section]];
    GMParticipant *participant = [participants objectAtIndex:indexPath.row];
    
    [parent displayAddressBookEntryForParticipant:participant];
    
    [table deselectRowAtIndexPath:indexPath animated:YES];
}

@end

