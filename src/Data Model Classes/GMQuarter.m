//
// GMQuarter.m
// Models an academic quarter
// Created by Group J5 for CS48
//

#import "GMQuarter.h"

@implementation GMQuarter

@synthesize year;
@synthesize quarter;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.year forKey:@"year"];
    [encoder encodeObject:self.quarter forKey:@"quarter"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super init])) {
        self.year = [decoder decodeIntegerForKey:@"year"];
        self.quarter = [decoder decodeObjectForKey:@"quarter"];
    }
    
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.year = 2011;
        self.quarter = @"Winter";
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %i", quarter, (int)year];
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMQuarter class]]) {
        GMQuarter *other = (GMQuarter *)object;
        if (other.year == self.year && [other.quarter isEqualToString:self.quarter])
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
    return (NSUInteger)self.year ^ [self.quarter hash];
}

@end
