//
//  GMForumPost.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/13/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMParticipant.h"

@interface GMForumPost : NSObject {
    NSString *postID;
    NSString *message;
    GMParticipant *author;
    NSDate *postDate;
}

@property (copy) NSString *postID;
@property (copy) NSString *message;
@property (retain) GMParticipant *author;
@property (copy) NSDate *postDate;

@end
