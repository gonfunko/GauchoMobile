//
//  GMiPadAssignmentsViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/16/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMiPadAssignmentsViewController.h"

@implementation GMiPadAssignmentsViewController

@synthesize date;
@synthesize longDate;
@synthesize ipadCalendar;
@synthesize visible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    assignmentListViewController.tableView.layer.borderWidth = 1.0;
    assignmentListViewController.tableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    assignmentListViewController.tableView.frame = CGRectMake(20, 300, self.view.frame.size.width - 40, self.view.frame.size.height - 320);
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadAssignments) 
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [cal components:NSDayCalendarUnit
                                                   fromDate:[NSDate date]];
    date.text = [NSString stringWithFormat:@"%i", dateComponents.day];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM d, YYYY"];
    longDate.text = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    ipadCalendar.dataSource = self;
    ipadCalendar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.visible = YES;
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    
    if ([[currentCourse assignments] count] == 0) {
        [assignmentListViewController loadAssignments];
    } else {
        [assignmentListViewController.tableView reloadData];
        [ipadCalendar reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.visible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [ipadCalendar reloadData];
}

- (void)loadAssignments {
    if (self.visible) {
        [assignmentListViewController loadAssignments];
    }
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMAssignment *assignment = [[[[GMDataSource sharedDataSource] currentCourse] assignments] objectAtIndex:indexPath.row];
    
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
    AssignmentDetailViewController *details = [[AssignmentDetailViewController alloc] initWithNibName:@"AssignmentDetailViewController" bundle:[NSBundle mainBundle]];
    details.assignment = assignment;
    details.tabBarController = (UITabBarController *)(self.navigationController.visibleViewController);
    UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:details];
    detailNav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:detailNav animated:YES];
    [details release];
    [detailNav release];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"GMCurrentCourseChangedNotification" 
                                                  object:nil];
    [super dealloc];
}

@end
