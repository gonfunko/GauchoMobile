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
#import "GMOForumTopicsViewController.h"
#import "GMOTableView.h"

@interface ForumViewController : UITableViewController <GMSourceFetcherDelegate> {
@private
    GMSourceFetcher *fetcher;
}

- (void)loadForums;

@end
