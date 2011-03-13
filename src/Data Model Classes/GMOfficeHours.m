//
// GMOfficeHours.m
// Models an office hours appointment
// Created by Group J5 for CS48
//

#import "GMOfficeHours.h"


@implementation GMOfficeHours

@synthesize day;
@synthesize time;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.day forKey:@"day"];
    [encoder encodeObject:self.time forKey:@"time"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.day = [decoder decodeObjectForKey:@"day"];
        self.time = [decoder decodeObjectForKey:@"time"];
    }
    
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.day = @"";
        self.time = [NSDate date];
    }
    
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMOfficeHours class]]) {
        GMOfficeHours *other = (GMOfficeHours *)object;
        if ([other.day isEqualToString:self.day] &&
            [other.time isEqualToDate:self.time])
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
    return [self.day hash] ^ [self.time hash];
}

@end
