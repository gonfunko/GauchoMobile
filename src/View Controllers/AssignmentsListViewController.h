//
//  AssignmentsListViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 12/16/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMAssignmentsParser.h"
#import "AssignmentDetailViewController.h"
#import "UITableView+GMAdditions.h"
#import "MBProgressHUD.h"

@interface AssignmentsListViewController : UITableViewController <GMSourceFetcherDelegate> {
    UITextField *noAssignmentsLabel;
    NSInteger pendingID;
    GMSourceFetcher *fetcher;
}

@property (retain) MBProgressHUD *HUD;

//Scrolls to the assignment with the specified assignment ID and highlights it in yellow
- (void)showAssignmentWithID:(NSNumber *)assignmentID;

- (void)loadAssignmentsWithLoadingView:(BOOL)showLoadingView;


@end
