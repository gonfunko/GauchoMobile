//
//  ForumPostsViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/11/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMSourceFetcher.h"
#import "GMForumsParser.h"
#import "GMForumPostTableCell.h"

@interface ForumPostsViewController : UITableViewController <GMSourceFetcherDelegate> {
@private
    GMForumTopic *topic;
    GMSourceFetcher *fetcher;
    NSDateFormatter *formatter;
    NSMutableDictionary *pictures;
}

@property (retain) GMForumTopic *topic;

- (void)loadPosts;

@end
