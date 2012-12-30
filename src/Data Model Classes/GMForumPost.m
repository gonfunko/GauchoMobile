//
//  GMForumPost.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/13/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMForumPost.h"

@implementation GMForumPost

@synthesize postID;
@synthesize message;
@synthesize author;
@synthesize postDate;

- (id)init {
    if (self = [super init]) {
        self.postID = @"";
        self.message = @"";
        self.author = [[GMParticipant alloc] init];
        self.postDate = [NSDate date];
    }
    
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMForumPost class]]) {
        GMForumPost *other = (GMForumPost *)object;
        if ([other.postID isEqualToString:self.postID] &&
            [other.message isEqualToString:self.message] &&
            [other.author isEqualTo:self.author] &&
            [other.postDate isEqualToDate:self.postDate])
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
    return [postID integerValue];
}

- (void)dealloc {
    self.postID = nil;
    self.message = nil;
    self.author = nil;
    self.postDate = nil;
    [super dealloc];
}

@end
