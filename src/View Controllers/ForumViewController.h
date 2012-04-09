//
//  ForumViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/7/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMForumsParser.h"
#import "MBProgressHUD.h"
#import "ForumTopicsViewController.h"
#import "GMSplitViewController.h"

@interface ForumViewController : UITableViewController <GMSourceFetcherDelegate> {
@private
    GMSourceFetcher *fetcher;
    MBProgressHUD *HUD;
    BOOL loading;
    BOOL visible;
}

@property (assign) BOOL visible;

- (void)loadForumsWithLoadingView:(BOOL)flag;

@end
