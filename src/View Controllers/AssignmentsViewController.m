//
//  GMAssignmentsViewController.m
//  Handles presentation and interaction with the list of assignments
//  Created by Group J5 for CS48
//


#import "AssignmentsViewController.h"

@implementation AssignmentsViewController

@synthesize tableView;

- (void)dealloc
{
    [fetcher release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"Assignments";
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    fetcher = [[GMSourceFetcher alloc] init];
    noAssignmentsLabel = nil;
    
    if ([[currentCourse assignments] count] == 0) {
        [self loadAssignmentsWithLoadingView:YES];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    TKCalendarMonthView *monthView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES];
    monthView.delegate = self;
    monthView.dataSource = self;
    [self.view addSubview:monthView];
    [monthView release];
    [monthView reload];
        calendar = monthView;
    }
    
    self.tableView.scrollsToTop = YES;

    pendingID = 0;
    
    calendar.hidden = NO;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.tableView.frame = CGRectMake(0, calendar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - calendar.frame.size.height);
    }
    
    noAssignmentsLabel = [[UITextField alloc] initWithFrame:CGRectMake(0, (self.tableView.frame.size.height - 30) / 2 - 25, self.tableView.frame.size.width, 30)];
    noAssignmentsLabel.enabled = NO;
    noAssignmentsLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    noAssignmentsLabel.text = @"No Assignments";
    noAssignmentsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    noAssignmentsLabel.textColor = [UIColor grayColor];
    noAssignmentsLabel.textAlignment = UITextAlignmentCenter;
    noAssignmentsLabel.hidden = YES;
    [self.tableView addSubview:noAssignmentsLabel];
    [noAssignmentsLabel release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.visibleViewController.navigationItem.title = @"Assignments";
    
    UIBarButtonItem *import = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(import)];
    self.navigationController.visibleViewController.navigationItem.rightBarButtonItem = import;
    [import release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Data Loading Methods

- (void)loadAssignmentsWithLoadingView:(BOOL)flag {
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
        [fetcher assignmentsForCourse:currentCourse withDelegate:self];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading assignments failed with error: %@", [error description]);
    loading = NO;
    [HUD hide:YES];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    loading = NO;
    [HUD hide:YES];
    
    [[[GMDataSource sharedDataSource] currentCourse] removeAllAssignments];
    
    GMAssignmentsParser *parser = [[GMAssignmentsParser alloc] init];
    NSArray *assignments = [parser assignmentsFromSource:source];
    
    for (GMAssignment *assignment in assignments) {
        [[[GMDataSource sharedDataSource] currentCourse] addAssignment:assignment];
    }
    
    [parser release];
    
    [self.tableView reloadData];
    
    if ([assignments count] == 0) {
        noAssignmentsLabel.hidden = NO;
    } else {
        noAssignmentsLabel.hidden = YES;
    }
    
    if ([calendar respondsToSelector:@selector(reload)]) {
        [calendar performSelector:@selector(reload)];
    }
    
    if (pendingID != 0) {
        [self showAssignmentWithID:[NSNumber numberWithInteger:pendingID]];
        pendingID = 0;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [[[[GMDataSource sharedDataSource] currentCourse] assignments] count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GMAssignment *assignment = [[[[GMDataSource sharedDataSource] currentCourse] assignments] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = assignment.description;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 25);
    button.layer.cornerRadius = 5.0;
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1.0);
    
    NSInteger offset = [[NSTimeZone localTimeZone] secondsFromGMTForDate:[NSDate date]];
    NSDate *now = [[NSDate date] dateByAddingTimeInterval:offset];
    if (assignment.submittedDate != nil) {
        [button setTitle:@"DONE" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor grayColor];
    } else if (assignment.dueDate != nil && [[assignment.dueDate earlierDate:now] isEqualToDate:assignment.dueDate]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"M/d"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [button setTitle:[NSString stringWithFormat:@"DUE %@", [formatter stringFromDate:assignment.dueDate]] forState:UIControlStateNormal];
        [formatter release];
        button.backgroundColor = [UIColor colorWithRed:163/255.0 green:0.0 blue:6.0/255.0 alpha:1.0];
        [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    } else if (assignment.dueDate != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"M/d"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [button setTitle:[NSString stringWithFormat:@"DUE %@", [formatter stringFromDate:assignment.dueDate]] forState:UIControlStateNormal];
        [formatter release];
        button.backgroundColor = [UIColor colorWithRed:0.0 green:139/255.0 blue:15.0/255.0 alpha:1.0];
        [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:@"" forState:UIControlStateNormal];
    }
    
    cell.accessoryView = button;
    
    return cell;
}

- (void)accessoryButtonTapped:(UIButton *)button withEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:self.tableView]];
    if (indexPath == nil)
        return;
    
    GMAssignment *assignment = [[[[GMDataSource sharedDataSource] currentCourse] assignments] objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *newString = @"";
    
    if ([[button titleForState:UIControlStateNormal] rangeOfString:@":"].location == NSNotFound) {
        [formatter setDateFormat:@"h:mm a"];
        newString = [formatter stringFromDate:assignment.dueDate];
    } else {
        [formatter setDateFormat:@"M/d"];
        newString = [NSString stringWithFormat:@"DUE %@", [formatter stringFromDate:assignment.dueDate]];
    }
    
    [button setTitle:newString forState:UIControlStateNormal];
    [formatter release];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMAssignment *assignment = [[[[GMDataSource sharedDataSource] currentCourse] assignments] objectAtIndex:indexPath.row];
    
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
    AssignmentDetailViewController *details = [[AssignmentDetailViewController alloc] initWithNibName:@"AssignmentDetailViewController" bundle:[NSBundle mainBundle]];
    details.assignment = assignment;
    details.tabBarController = (UITabBarController *)(self.navigationController.visibleViewController);
    [self.navigationController pushViewController:details animated:YES];
    [details release];
}

#pragma mark - Animation methods

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if ([theAnimation valueForKey:@"layer"] != nil) {
        [(CALayer *)[theAnimation valueForKey:@"layer"] removeFromSuperlayer];
    }
}

- (void)showAssignmentWithID:(NSNumber *)assignmentID {
    if ([[[[GMDataSource sharedDataSource] currentCourse] assignments] count] != 0) {
        
        NSArray *assignments = [[[GMDataSource sharedDataSource] currentCourse] assignments];
        
        for (int i = 0; i < [assignments count]; i++) {
            if (((GMAssignment *)[assignments objectAtIndex:i]).assignmentID == [assignmentID integerValue]) {
                GMAssignment *assignment = [assignments objectAtIndex:i];
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                
                CAGradientLayer *layer = [[CAGradientLayer alloc] init];
                
                CGColorRef first = [[UIColor colorWithRed:242/255.0 green:206/255.0 blue:68/255.0 alpha:1.0] CGColor];
                CGColorRef second = [[UIColor colorWithRed:239/255.0 green:172/255.0 blue:30/255.0 alpha:1.0] CGColor];
                
                layer.colors = [NSArray arrayWithObjects:(id)first, (id)second, nil];
                layer.cornerRadius = 15.0;
                layer.borderWidth = 1.0;
                layer.borderColor = [[UIColor grayColor] CGColor];
                layer.frame = CGRectMake(0, i * 44, [self.tableView frame].size.width, 44);
                [self.tableView.layer addSublayer:layer];
                [layer release];
                
                CATextLayer *description = [[CATextLayer alloc] init];
                description.frame = CGRectMake(10, 14, layer.frame.size.width - 20, layer.frame.size.height - 10);
                CGFontRef descriptionFont = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica-Bold" size:18.0].fontName);
                description.font = descriptionFont;
                CGFontRelease(descriptionFont);
                description.fontSize = 18.0;
                description.foregroundColor = [[UIColor blackColor] CGColor];
                description.contentsScale = [[UIScreen mainScreen] scale];
                description.string = assignment.description;
                [layer addSublayer:description];
                [description release];
                
                //From http://stackoverflow.com/questions/2690775/creating-a-pop-animation-similar-to-the-presentation-of-uialertview
                CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                                  animationWithKeyPath:@"transform"];
                
                CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
                CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
                CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
                CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
                
                NSArray *frameValues = [NSArray arrayWithObjects:
                                        [NSValue valueWithCATransform3D:scale1],
                                        [NSValue valueWithCATransform3D:scale2],
                                        [NSValue valueWithCATransform3D:scale3],
                                        [NSValue valueWithCATransform3D:scale4],
                                        nil];
                [animation setValues:frameValues];
                
                NSArray *frameTimes = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0],
                                       [NSNumber numberWithFloat:0.5],
                                       [NSNumber numberWithFloat:0.9],
                                       [NSNumber numberWithFloat:1.0],
                                       nil];    
                [animation setKeyTimes:frameTimes];
                
                animation.fillMode = kCAFillModeForwards;
                animation.removedOnCompletion = NO;
                animation.duration = .4;
                animation.delegate = self;
                [animation setValue:layer forKey:@"layer"];
                
                [layer addAnimation:animation forKey:@"popup"];
                
                return;
            }
        }
    } else {
        pendingID = [assignmentID integerValue];
    }
}

#pragma mark -
#pragma mark Calendar View Methods

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)month animated:(BOOL)animated {
    self.tableView.frame = CGRectMake(0, monthView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - monthView.frame.size.height);
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date {
    NSArray *assignments = [[[GMDataSource sharedDataSource] currentCourse] assignments];
    
    NSString *dateString = [[[date description] componentsSeparatedByString:@" "] objectAtIndex:0];
  
    for (GMAssignment *assignment in assignments) {
        NSString *dueDateString = [[[assignment.dueDate description] componentsSeparatedByString:@" "] objectAtIndex:0];
        
        if ([dateString isEqualToString:dueDateString]) {
            [self showAssignmentWithID:[NSNumber numberWithInteger:assignment.assignmentID]];
            return;
        }
    }
}

- (NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {
    NSArray *assignments = [[[GMDataSource sharedDataSource] currentCourse] assignments];
    NSMutableArray *marks = [NSMutableArray array];
    
    NSMutableDictionary *lookup = [[NSMutableDictionary alloc] init];
    for (GMAssignment *assignment in assignments) {
        TKDateInformation info = [assignment.dueDate dateInformation];
        [lookup setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%i:%i", info.month, info.day]];
    }
    
    NSDate *d = startDate;
    while (TRUE) {
        TKDateInformation info = [d dateInformation];
        
        if ([[lookup objectForKey:[NSString stringWithFormat:@"%i:%i", info.month, info.day]] isEqualToNumber:[NSNumber numberWithBool:YES]])
            [marks addObject:[NSNumber numberWithBool:YES]];
        else
            [marks addObject:[NSNumber numberWithBool:NO]];
        
        info.day++;
        d = [NSDate dateFromDateInformation:info];
        
        if ([d compare:lastDate]==NSOrderedDescending) 
            break;
    }
    
    [marks removeObjectAtIndex:0];
    [marks addObject:[NSNumber numberWithBool:NO]];
    [lookup release];
    
    return marks;
}

- (void)weekViewSelectedDate:(NSDate *)date {
    NSArray *assignments = [[[GMDataSource sharedDataSource] currentCourse] assignments];
    NSDateComponents *selectedDateComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    
    for (GMAssignment *assignment in assignments) {
        NSDateComponents *assignmentComponents = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:assignment.dueDate];
        
        if ([assignmentComponents isEqual:selectedDateComponents]) {
            [self showAssignmentWithID:[NSNumber numberWithInteger:assignment.assignmentID]];
            return;
        }
    }
}

#pragma mark - Importing Events

- (void)import {
    EKEventStore *store = [[EKEventStore alloc] init];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            [self performSelectorOnMainThread:@selector(_import) withObject:nil waitUntilDone:NO];
        }];
    } else {
        [self _import];
    }
    
    [store release];
}

-(void)_import {
    EKEventStore *store = [[EKEventStore alloc] init];
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0") || [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {
        NSArray *assignments = [[[GMDataSource sharedDataSource] currentCourse] assignments];
        
        for (GMAssignment *assignment in assignments) {
            EKEvent *newEvent = [EKEvent eventWithEventStore:store];
            newEvent.title = assignment.description;
            newEvent.startDate = [assignment.dueDate dateByAddingTimeInterval:-3600];
            newEvent.endDate = assignment.dueDate;
            newEvent.calendar = [store defaultCalendarForNewEvents];
            
            [store saveEvent:newEvent span:EKSpanThisEvent error:nil];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Assignments Imported"
                                                        message:[NSString stringWithFormat:@"Your assignments have been successfully imported into the calendar %@", [store defaultCalendarForNewEvents].title]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") && [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] != EKAuthorizationStatusAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Import Assignments"
                                                        message:@"GauchoMobile does not have access to your calendars. Open Settings > Privacy > Calendars, enable access and try again."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
    
    [store release];
}


@end
