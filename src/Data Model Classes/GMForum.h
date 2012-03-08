//
//  GMForum.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/3/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMForum : NSObject {
    NSString *title;
    NSString *forumDescription;
    NSString *forumID;
}

@property (copy) NSString *title;
@property (copy) NSString *forumDescription;
@property (copy) NSString *forumID;

@end
