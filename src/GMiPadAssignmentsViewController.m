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
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadAssignments) 
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit
                                                   fromDate:[NSDate date]];
    date.text = [NSString stringWithFormat:@"%i", dateComponents.day];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM d, YYYY"];
    longDate.text = [formatter stringFromDate:[NSDate date]];
    
    ipadCalendar.dataSource = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadAssignments {
    [self loadAssignmentsWithLoadingView:YES];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    [super sourceFetchSucceededWithPageSource:source];
    [ipadCalendar reloadData];
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
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"GMCurrentCourseChangedNotification" 
                                                  object:nil];
    [super dealloc];
}

@end
