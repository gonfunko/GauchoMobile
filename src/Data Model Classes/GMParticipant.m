//
// GMParticipant.m
// Models a participant on GauchoSpace
// Created by Group J5 for CS48
//

#import "GMParticipant.h"


@implementation GMParticipant

@synthesize name;
@synthesize city;
@synthesize country;
@synthesize lastAccess;
@synthesize userID;
@synthesize imageURL;
@synthesize inAddressBook;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.country forKey:@"country"];
    [encoder encodeObject:self.lastAccess forKey:@"lastAccess"];
    [encoder encodeInteger:self.userID forKey:@"userID"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeBool:inAddressBook forKey:@"inAddressBook"];
}

- (id)initWithCoder:(NSCoder *)decoder {

    if ((self = [super init])) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.country = [decoder decodeObjectForKey:@"country"];
        self.lastAccess = [decoder decodeObjectForKey:@"lastAccess"];
        self.userID = [decoder decodeIntegerForKey:@"userID"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.inAddressBook = [decoder decodeBoolForKey:@"inAddressBook"];
    }
    
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.name = @"";
        self.city = @"";
        self.country = @"";
        self.lastAccess = [NSDate date];
        self.userID = 0;
        self.imageURL = [NSURL URLWithString:@"http://www.example.com"];
        self.inAddressBook = NO;
    }
    
    return self;
}

- (NSString *)lastName {
    NSString *lastName = @"";
    NSArray *names = [self.name componentsSeparatedByString:@" "];
    
    if ([names count] == 2) {
        lastName = [names objectAtIndex:1];
    }
    else {
        if ([[names objectAtIndex:1] length] <= 3) {
            for (int i = 1; i < [names count]; i++) {
                lastName = [lastName stringByAppendingString:[names objectAtIndex:i]];
                if (i != [names count] - 1) {
                    lastName = [lastName stringByAppendingString:@" "];
                }
            }
        }
        else {
            lastName = [names lastObject];
        }
    }
    
    lastName = [[[lastName substringToIndex:1] uppercaseString] stringByAppendingString:[lastName substringFromIndex:1]];
    
    return lastName;
}

- (NSString *)firstCharacterOfLastName {
    return [[[self lastName] substringToIndex:1] uppercaseString];
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMParticipant class]]) {
        GMParticipant *other = (GMParticipant *)object;
        if (other.userID == self.userID)
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
    return (NSUInteger)self.userID;
}

- (NSString *)description {
    return self.name;
}

@end
