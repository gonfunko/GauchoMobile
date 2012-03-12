//
//  GMForumPostsParser.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/13/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "TFHpple.h"
#include "GMForum.h"
#include "GMForumTopic.h"
#include "GMForumPost.h"

@interface GMForumsParser : NSObject

- (NSArray *)forumsFromSource:(NSString *)html;
- (NSArray *)forumTopicsFromSource:(NSString *)html;
- (NSArray *)forumPostsFromSource:(NSString *)html;
- (NSDate *)dateFromDateString:(NSString *)dateString;

@end
