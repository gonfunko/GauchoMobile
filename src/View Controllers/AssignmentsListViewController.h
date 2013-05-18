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
#import "GMOTableView.h"

@interface AssignmentsListViewController : UITableViewController <GMSourceFetcherDelegate> {
    NSInteger pendingID;
    GMSourceFetcher *fetcher;
}

//Scrolls to the assignment with the specified assignment ID and highlights it in yellow
- (void)showAssignmentWithID:(NSNumber *)assignmentID;

- (void)loadAssignments;


@end
