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
#import "GMForumTopicTableCell.h"
#import "GMOForumPostsViewController.h"
#import "UITableView+GMAdditions.h"

@interface ForumTopicsViewController : UITableViewController <GMSourceFetcherDelegate> {
@private
    GMForum *forum;
    GMSourceFetcher *fetcher;
    UITextField *noTopicsLabel;
    
    IBOutlet GMForumTopicTableCell *topicCell;
}

@property (retain) GMForum *forum;
@property (nonatomic, retain) GMForumTopicTableCell *topicCell;

- (void)loadTopics;

@end
