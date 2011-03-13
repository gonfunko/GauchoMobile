//
// GMParticipantsParser.h
// Parses the GauchoSpace Participants page and returns an array of GMParticipant objects.
// Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>
#import "GMParticipant.h"
#import <AddressBook/AddressBook.h>

@interface GMParticipantsParser : NSObject {

}

//Returns an array of GMParticipant objects given valid HTML source for the GauchoSpace participants page
//May raise an NSRangeException if given malformed input
- (NSArray *)participantsFromSource:(NSString *)source;

//Returns an NSDate object given a timestamp as an NSString in the format found on the GauchoSpace participants page, or nil if timeStamp is "Never"
//eg now, 32 mins 21 secs, 23 days 8 hours, etc.
//Returns the current date given a malformed string
- (NSDate *)dateFromAccessTimestamp:(NSString *)timeStamp;

@end
