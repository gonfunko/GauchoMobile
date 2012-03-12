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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMDataSource *dataSource = [GMDataSource sharedDataSource];
    [dataSource setCurrentCourse:[[dataSource allCourses] objectAtIndex:indexPath.row]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    //Create our view controllers and add them to the tab bar controller
    DashboardViewController *dashboardController = [[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:[NSBundle mainBundle]];
    dashboardController.title = @"Dashboard";
    dashboardController.tabBarItem.image = [UIImage imageNamed:@"dashboard.png"];
    
    AssignmentsViewController *assignmentsController = [[AssignmentsViewController alloc] initWithNibName:@"AssignmentsViewController" bundle:[NSBundle mainBundle]];
    assignmentsController.title = @"Assignments";
    assignmentsController.tabBarItem.image = [UIImage imageNamed:@"assignments.png"];
   
	ParticipantsViewController *participantsController = [[ParticipantsViewController alloc] initWithNibName:@"ParticipantsViewController" bundle:[NSBundle mainBundle]];
    participantsController.title = @"People";
    participantsController.tabBarItem.image = [UIImage imageNamed:@"participants.png"];

	GradesViewController *gradesController = [[GradesViewController alloc] initWithNibName:@"GradesViewController" bundle:[NSBundle mainBundle]];
    gradesController.title = @"Grades";
    gradesController.tabBarItem.image = [UIImage imageNamed:@"grades.png"];
    
    ForumViewController *forumController = [[ForumViewController alloc] initWithNibName:@"ForumViewController" bundle:[NSBundle mainBundle]];
    forumController.title = @"Forums";
    forumController.tabBarItem.image = [UIImage imageNamed:@"forums.png"];
    
    tabBarController.navigationItem.title = @"Dashboard";
    [tabBarController setViewControllers:[NSArray arrayWithObjects:dashboardController, assignmentsController, participantsController, gradesController, forumController, nil]];
    [self.navigationController pushViewController:tabBarController animated:YES];
    
    [tabBarController release];
    [dashboardController release];
    [assignmentsController release];
    [gradesController release];
    [participantsController release];
    [forumController release];
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
    [self.navigationController presentModalViewController:controller animated:YES];
    [controller release];
    
    [self.tableView reloadData];
}


@end
