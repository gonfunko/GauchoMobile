//
//  GMForum.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/3/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMForum.h"

@implementation GMForum

@synthesize title;
@synthesize forumDescription;
@synthesize forumID;
@synthesize topics;

- (id)init {
    if (self = [super init]) {
        self.title = @"";
        self.forumDescription = @"";
        self.forumID = @"";
        self.topics = [NSArray array];
    }
    
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMForum class]]) {
        GMForum *other = (GMForum *)object;
        if ([other.title isEqualToString:self.title] &&
            [other.forumDescription isEqualToString:self.forumDescription] &&
            [other.forumID isEqualToString:self.forumID] &&
            [other.topics isEqualToArray:self.topics])
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
    return [forumID integerValue];
}

- (void)dealloc {
    self.title = nil;
    self.forumDescription = nil;
    self.forumID = nil;
    self.topics = nil;
    [super dealloc];
}

@end
