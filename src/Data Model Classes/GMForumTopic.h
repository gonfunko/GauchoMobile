//
//  GMForumTopic.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/3/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMParticipant.h"

@interface GMForumTopic : NSObject {
    NSString *title;
    NSString *topicID;
    NSInteger replies;
    GMParticipant *author;
    NSDate *lastPostDate;
}

@property (copy) NSString *title;
@property (copy) NSString *topicID;
@property (assign) NSInteger replies;
@property (retain) GMParticipant *author;
@property (copy) NSDate *lastPostDate;

@end
