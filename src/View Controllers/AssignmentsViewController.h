//
//  GMAssignmentsViewController.h
//  Handles presentation and interaction with the list of assignments
//  Created by Group J5 for CS48
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "GMDataSource.h"
#import "GMWeekView.h"
#import "TKCalendarMonthView.h"
#import "NSDate+TKCategory.h"
#import "MBProgressHUD.h"
#import "AssignmentsListViewController.h"

@interface AssignmentsViewController : UIViewController <TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource> {
@protected
    AssignmentsListViewController *assignmentListViewController;
    MBProgressHUD *HUD;
    UIView *calendar;
}

@end
