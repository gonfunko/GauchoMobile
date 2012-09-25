//
//  GMAssignmentsViewController.h
//  Handles presentation and interaction with the list of assignments
//  Created by Group J5 for CS48
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMAssignmentsParser.h"
#import "GMWeekView.h"
#import "TKCalendarMonthView.h"
#import "NSDate+TKCategory.h"
#import "AssignmentDetailViewController.h"
#import "MBProgressHUD.h"
#import "UITableView+GMAdditions.h"

@interface AssignmentsViewController : UIViewController <GMSourceFetcherDelegate, TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource> {
@protected
    GMSourceFetcher *fetcher;
    MBProgressHUD *HUD;
    UITextField *noAssignmentsLabel;
    UIView *calendar;
    BOOL loading;
    NSInteger pendingID;
    
    IBOutlet UITableView *tableView;
}

@property (retain) UITableView *tableView;

//Loads assignments from the network, optionally with or without the yellow loading view
- (void)loadAssignmentsWithLoadingView:(BOOL)flag;

//Scrolls to the assignment with the specified assignment ID and highlights it in yellow
- (void)showAssignmentWithID:(NSNumber *)assignmentID;

@end
