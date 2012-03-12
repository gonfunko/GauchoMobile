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
#import "GMLoadingView.h"
#import "ForumTopicsViewController.h"

@interface ForumViewController : UITableViewController <GMSourceFetcherDelegate> {
@private
    GMSourceFetcher *fetcher;
    GMLoadingView *loadingView;
    BOOL loading;
}

- (void)loadForumsWithLoadingView:(BOOL)flag;

@end
