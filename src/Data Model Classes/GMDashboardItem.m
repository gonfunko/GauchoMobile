//
//  GMDashboardItem.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GMDashboardItem.h"


@implementation GMDashboardItem

@synthesize dateRange;
@synthesize contents;
@synthesize links;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.dateRange forKey:@"dateRange"];
    [encoder encodeObject:self.contents forKey:@"contents"];
    [encoder encodeObject:self.links forKey:@"links"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.dateRange = [decoder decodeObjectForKey:@"dateRange"];
        self.contents = [decoder decodeObjectForKey:@"contents"];
        self.links = [decoder decodeObjectForKey:@"links"];
    }
    
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.dateRange = @"";
        self.contents = @"";
        self.links = [NSArray array];
    }
    
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMDashboardItem class]]) {
        GMDashboardItem *other = (GMDashboardItem *)object;
        if ([other.contents isEqualToString:self.contents] && [other.dateRange isEqualToString:self.dateRange])
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

- (NSUInteger)hash
{
    return [self.contents hash] ^ [self.dateRange hash];
}

- (void)dealloc {
    self.dateRange = nil;
    self.contents = nil;
    self.links = nil;
    [super dealloc];
}

@end
