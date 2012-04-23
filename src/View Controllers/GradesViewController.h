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
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

@interface GradesViewController : UIViewController <GMSourceFetcherDelegate, EGORefreshTableHeaderDelegate> {
@private
    GMSourceFetcher *fetcher;
    MBProgressHUD *HUD;
    EGORefreshTableHeaderView *reloadView;
    UITextField *noGradesLabel;
    BOOL loading;
    BOOL visible;
    NSInteger pendingID;
    IBOutlet UITableView *tableView;
}

@property (retain) UITableView *tableView;
@property (assign) BOOL visible;

//Loads grades from the network, optionally with or without the yellow loading view
- (void)loadGradesWithLoadingView:(BOOL)flag;

//Scrolls to and highlights the grade with the given grade ID in yellow
- (void)showGradeWithID:(NSNumber *)gradeID;

@end
