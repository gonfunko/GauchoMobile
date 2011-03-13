//
//  GradesViewController.h
//  Handles presentation and interaction with the list of grades
//  Created by Group J5 for CS48
//

#import <UIKit/UIKit.h>
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMGradesParser.h"
#import "GMGradesTableViewCell.h"
#import "GMLoadingView.h"
#import "EGORefreshTableHeaderView.h"
#import "GMGradesGraphView.h"

@interface GradesViewController : UIViewController <GMSourceFetcherDelegate, EGORefreshTableHeaderDelegate> {
@private
    GMSourceFetcher *fetcher;
    GMLoadingView *loadingView;
    EGORefreshTableHeaderView *reloadView;
    GMGradesGraphView *graphView;
    BOOL loading;
    NSInteger pendingID;
    IBOutlet UITableView *tableView;
}

@property (retain) UITableView *tableView;

//Loads grades from the network, optionally with or without the yellow loading view
- (void)loadGradesWithLoadingView:(BOOL)flag;

//Scrolls to and highlights the grade with the given grade ID in yellow
- (void)showGradeWithID:(NSNumber *)gradeID;

//Handles device rotation by switching between the landscape and portrait views
- (void)adjustForRotation;

@end
