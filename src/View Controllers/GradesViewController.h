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
#import "UITableView+GMAdditions.h"

@interface GradesViewController : UITableViewController <GMSourceFetcherDelegate> {
@private
    GMSourceFetcher *fetcher;
    MBProgressHUD *HUD;
    UITextField *noGradesLabel;
    NSInteger pendingID;
}

//Loads grades from the network
- (void)loadGradesWithLoadingView:(BOOL)flag;

//Scrolls to and highlights the grade with the given grade ID in yellow
- (void)showGradeWithID:(NSNumber *)gradeID;

@end
