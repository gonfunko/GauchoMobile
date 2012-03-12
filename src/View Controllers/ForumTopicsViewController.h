//
//  ForumTopicsViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/11/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMForumsParser.h"
#import "GMLoadingView.h"
#import "GMForumTopicTableCell.h"
#import "ForumPostsViewController.h"

@interface ForumTopicsViewController : UITableViewController <GMSourceFetcherDelegate> {
@private
    GMForum *forum;
    GMSourceFetcher *fetcher;
    GMLoadingView *loadingView;
    BOOL loading;
    
    IBOutlet GMForumTopicTableCell *topicCell;
}

@property (retain) GMForum *forum;
@property (nonatomic, retain) GMForumTopicTableCell *topicCell;

- (void)loadTopicsWithLoadingView:(BOOL)flag;

@end
