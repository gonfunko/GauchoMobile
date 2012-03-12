//
//  GMForumTopic.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/3/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMForumTopic.h"

@implementation GMForumTopic

@synthesize title;
@synthesize topicID;
@synthesize replies;
@synthesize author;
@synthesize lastPostDate;
@synthesize posts;

- (id)init {
    if (self = [super init]) {
        self.title = @"";
        self.topicID = @"";
        self.replies = 0;
        self.author = nil;
        self.lastPostDate = [NSDate date];
        self.posts = [NSArray array];
    }
    
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMForumTopic class]]) {
        GMForumTopic *other = (GMForumTopic *)object;
        if ([other.title isEqualToString:self.title] &&
            [other.topicID isEqualToString:self.topicID] &&
            other.replies == self.replies &&
            [other.author isEqualTo:self.author] &&
            [other.lastPostDate isEqualToDate:self.lastPostDate] &&
            [other.posts isEqualToArray:self.posts])
            return YES;
        else
            return NO;
    }
    else
        return NO;
}

- (BOOL)isEqual:(id)object {
    return [self isEqualTo:object];
}

- (NSUInteger)hash {
    return [topicID integerValue];
}

- (void)dealloc {
    self.title = nil;
    self.topicID = nil;
    self.author = nil;
    self.lastPostDate = nil;
    self.posts = nil;
    [super dealloc];
}

@end
