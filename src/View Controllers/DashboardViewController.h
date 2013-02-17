//
//  DashboardViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMDashboardItem.h"
#import "GMDashboardParser.h"
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMTextViewTableCell.h"
#import "WebViewController.h"

@interface DashboardViewController : UITableViewController <GMSourceFetcherDelegate> {
@private
    GMSourceFetcher *fetcher;
    NSDateFormatter *dateFormatter;
}

//Loads dashboard items from the network
- (void)loadDashboard;

@end
