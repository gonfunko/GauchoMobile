//
//  GMForumTopicView.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/15/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMForumPost.h"
#import "ASIHTTPRequest.h"
#import "GMDataSource.h"

@interface GMForumTopicView : UIView {
    NSMutableDictionary *pictures;
    NSMutableArray *photoRequests;
    NSMutableDictionary *photoLayers;
}

- (void)setPosts:(NSArray *)forumPosts;
- (void)loadPicturesForParticipants:(NSArray *)forumPosts;

@end
