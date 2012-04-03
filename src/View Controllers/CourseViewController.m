//
//  GMCourseViewController.m
//  Handles presentation and interaction with the list of courses
//  Created by Group J5 for CS48
//

#import "CourseViewController.h"


@implementation CourseViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GMLoginSuccessfulNotification" object:nil];
    [fetcher release];
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
    self.navigationItem.title = @"Courses";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStylePlain target:self action:@selector(logOut)];
    self.navigationItem.leftBarButtonItem = logOut;
    [logOut release];
    
    fetcher = [[GMSourceFetcher alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectCurrentCourse) name:@"GMLoginSuccessfulNotification" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[GMDataSource sharedDataSource] allCourses] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = ((GMCourse *)[[[GMDataSource sharedDataSource] allCourses] objectAtIndex:indexPath.row]).name;
    cell.detailTextLabel.text = [((GMCourse *)[[[GMDataSource sharedDataSource] allCourses] objectAtIndex:indexPath.row]).quarter description];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMDataSource *dataSource = [GMDataSource sharedDataSource];
    [dataSource setCurrentCourse:[[dataSource allCourses] objectAtIndex:indexPath.row]];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        MainTabBarViewController *tabBarController = [[MainTabBarViewController alloc] init];
        [self.navigationController pushViewController:tabBarController animated:YES];
        [tabBarController release];
    }
}

- (void)selectCurrentCourse {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        //We need to select the row after a delay, because otherwise it gets deselected as part of the login view dismissing or something along those lines.
        [self performSelector:@selector(_selectCurrentCourse) withObject:nil afterDelay:0.5];
    }
}

- (void)_selectCurrentCourse {
    NSArray *allCourses = [[GMDataSource sharedDataSource] allCourses];
    NSInteger index = [allCourses indexOfObject:[[GMDataSource sharedDataSource] currentCourse]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)logOut {
    //Log out from GauchoSpace
    [fetcher logout];
    
    //Write out the cache
    [[GMDataSource sharedDataSource] archiveData];
    //Clear everything out
    [[GMDataSource sharedDataSource] removeAllCourses];
    //Reset the active username and password
    [[GMDataSource sharedDataSource] setUsername:@""];
    [[GMDataSource sharedDataSource] setPassword:@""];
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.stuffediggy.gauchomobile" accessGroup:nil];
    [keychain setObject:@"" forKey:(id)kSecAttrAccount];
    [keychain setObject:@"" forKey:(id)kSecValueData];
    [keychain release];
    
    //Create and present the login controller
    LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self.navigationController presentModalViewController:controller animated:YES];
    } else {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(dismissMasterPopover)];
        [self.splitViewController presentModalViewController:controller animated:YES];
    }
    [controller release];
    
    [self.tableView reloadData];
}


@end
