//
// GMAssignment.m
// Models an assignment on GauchoSpace
// Created by Group J5 for CS48
//

#import "GMAssignment.h"

@implementation GMAssignment

@synthesize description;
@synthesize dueDate;
@synthesize submittedDate;
@synthesize assignmentID;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.dueDate forKey:@"dueDate"];
    [encoder encodeObject:self.submittedDate forKey:@"submittedDate"];
    [encoder encodeInteger:self.assignmentID forKey:@"assignmentID"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.description = [decoder decodeObjectForKey:@"description"];
        self.dueDate = [decoder decodeObjectForKey:@"dueDate"];
        self.submittedDate = [decoder decodeObjectForKey:@"submittedDate"];
        self.assignmentID = [decoder decodeIntegerForKey:@"assignmentID"];
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.description = @"";
        self.dueDate = nil;
        self.submittedDate = nil;
        self.assignmentID = 0;
    }
    
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMAssignment class]]) {
        GMAssignment *other = (GMAssignment *)object;
        if (other.assignmentID == self.assignmentID)
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
    return (NSUInteger)assignmentID;
}

- (void)dealloc {
    self.description = nil;
    self.dueDate = nil;
    self.submittedDate = nil;
    [super dealloc];
}

@end
