//
//  GMAssignmentsViewController.m
//  Handles presentation and interaction with the list of assignments
//  Created by Group J5 for CS48
//


#import "AssignmentsViewController.h"

@implementation AssignmentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[GMDataSource sharedDataSource] addObserver:self
                                          forKeyPath:@"currentCourse.assignments"
                                             options:NSKeyValueObservingOptionNew
                                             context:nil];
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"Assignments";
    
    assignmentListViewController = [[AssignmentsListViewController alloc] initWithNibName:@"AssignmentsListViewController"
                                                                                   bundle:[NSBundle mainBundle]];
    
    [self addChildViewController:assignmentListViewController];
    [self.view addSubview:assignmentListViewController.view];
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    
    if ([[currentCourse assignments] count] == 0) {
        [assignmentListViewController loadAssignments];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        TKCalendarMonthView *monthView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES];
        monthView.delegate = self;
        monthView.dataSource = self;
        [self.view addSubview:monthView];
        [monthView release];
        [monthView reload];
        calendar = monthView;
        
        assignmentListViewController.view.frame = CGRectMake(0, monthView.frame.origin.y + monthView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - monthView.frame.size.height);
    }
    
    calendar.hidden = NO;
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [(TKCalendarMonthView *)calendar reload];
}

- (void)showAssignmentWithID:(NSNumber *)assignmentID {
    [assignmentListViewController showAssignmentWithID:assignmentID];
}

#pragma mark -
#pragma mark Calendar View Methods

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)month animated:(BOOL)animated {
    assignmentListViewController.view.frame = CGRectMake(0, monthView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - monthView.frame.size.height);
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date {
    NSArray *assignments = [[[GMDataSource sharedDataSource] currentCourse] assignments];
    
    NSString *dateString = [[[date description] componentsSeparatedByString:@" "] objectAtIndex:0];
  
    for (GMAssignment *assignment in assignments) {
        NSString *dueDateString = [[[assignment.dueDate description] componentsSeparatedByString:@" "] objectAtIndex:0];
        
        if ([dateString isEqualToString:dueDateString]) {
            [assignmentListViewController showAssignmentWithID:[NSNumber numberWithInteger:assignment.assignmentID]];
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
            [assignmentListViewController showAssignmentWithID:[NSNumber numberWithInteger:assignment.assignmentID]];
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

- (void)dealloc {
    [[GMDataSource sharedDataSource] removeObserver:self forKeyPath:@"currentCourse.assignments"];
    [super dealloc];
}

@end
