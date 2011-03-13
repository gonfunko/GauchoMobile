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
#import "GMLoadingView.h"
#import "EGORefreshTableHeaderView.h"
#import "TKCalendarMonthView.h"
#import "NSDate+TKCategory.h"

@interface AssignmentsViewController : UIViewController <GMSourceFetcherDelegate, EGORefreshTableHeaderDelegate, TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource> {
@private
    GMSourceFetcher *fetcher;
    GMLoadingView *loadingView;
    EGORefreshTableHeaderView *reloadView;
    TKCalendarMonthView *calendar;
    BOOL loading;
    NSInteger pendingID;
    
    IBOutlet UITableView *tableView;
}

@property (retain) UITableView *tableView;

//Handles the device being rotated by switching between the landscape and portrait view
- (void)adjustForRotation;

//Loads assignments from the network, optionally with or without the yellow loading view
- (void)loadAssignmentsWithLoadingView:(BOOL)flag;

//Scrolls to the assignment with the specified assignment ID and highlights it in yellow
- (void)showAssignmentWithID:(NSNumber *)assignmentID;

@end
