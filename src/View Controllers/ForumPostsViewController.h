//
//  ForumPostsViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/11/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMSourceFetcher.h"
#import "GMForumsParser.h"
#import "MBProgressHUD.h"
#import "GMForumTopicView.h"

@interface ForumPostsViewController : UIViewController <GMSourceFetcherDelegate> {
@private
    GMForumTopic *topic;
    GMSourceFetcher *fetcher;
    MBProgressHUD *HUD;
    BOOL loading;
    
    IBOutlet GMForumTopicView *postsView;
}

@property (retain) GMForumTopic *topic;
@property (nonatomic, retain) GMForumTopicView *postsView;

- (void)loadPostsWithLoadingView:(BOOL)flag;

@end
