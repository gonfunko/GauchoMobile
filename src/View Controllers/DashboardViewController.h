//
//  DashboardViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMDashboardItem.h"
#import "GMDashboardParser.h"
#import "GMLoadingView.h"
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMTextViewTableCell.h"
#import "WebViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface DashboardViewController : UITableViewController <GMSourceFetcherDelegate, EGORefreshTableHeaderDelegate> {
@private
    GMSourceFetcher *fetcher;
    GMLoadingView *loadingView;
    EGORefreshTableHeaderView *reloadView;
    BOOL loading;
}

//Loads dashboard items from the network, optionally with or without the yellow loading view
- (void)loadDashboardWithLoadingView:(BOOL)flag;

@end
