//
// GMGrade.m
// Models a grade on GauchoSpace
// Created by Group J5 for CS48
//

#import "GMGrade.h"

@implementation GMGrade

@synthesize description;
@synthesize score;
@synthesize max;
@synthesize feedback;
@synthesize gradeID;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeInteger:self.score forKey:@"score"];
    [encoder encodeInteger:self.max forKey:@"max"];
    [encoder encodeObject:self.feedback forKey:@"feedback"];
    [encoder encodeInteger:self.gradeID forKey:@"gradeID"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.description = [decoder decodeObjectForKey:@"description"];
        self.score = [decoder decodeIntegerForKey:@"score"];
        self.max = [decoder decodeIntegerForKey:@"max"];
        self.feedback = [decoder decodeObjectForKey:@"lastAccess"];
        self.gradeID = [decoder decodeIntegerForKey:@"gradeID"];
    }
    
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.description = @"";
        self.score = 0;
        self.max = 0;
        self.gradeID = 0;
        self.feedback = @"";
    }
    
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMGrade class]]) {
        GMGrade *other = (GMGrade *)object;
        if ([other.description isEqualToString:self.description] &&
            other.score == self.score &&
            other.max == self.max)
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
    return [self.description hash] ^ 
    (NSUInteger)score ^
    (NSUInteger)max;
}

@end
