//
// GMParticipantsParser.m
// Parses the GauchoSpace Participants page and returns an array of GMParticipant objects.
// Created by Group J5 for CS48
//

#import "GMParticipantsParser.h"


@implementation GMParticipantsParser

- (NSArray *)participantsFromSource:(NSString *)source {
    NSMutableArray *participants = [[[NSMutableArray alloc] init] autorelease];
    
    //Separate all the tables
	NSArray *tables = [source componentsSeparatedByString:@"<table"];
    
    //The participants are in the third table; separate every row of that table
    NSArray *rows = [[tables objectAtIndex:2] componentsSeparatedByString:@"<tr"];

    //The first 3 rows are useless markup, as is the last; loop through the data rows
    for (int i = 2; i < [rows count] - 1; i++) {
        NSString *currentRow = [rows objectAtIndex:i];
        
        //Identify starting location of the user ID
        NSRange cruftRange = [currentRow rangeOfString:@"href=\"https://gauchospace.ucsb.edu/courses/user/view.php?id="];
        currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
        //Find end of the user ID
        int idEnd = [currentRow rangeOfString:@"&"].location;
        //Extract the user ID
        NSString *userID = [currentRow substringWithRange:NSMakeRange(0, idEnd)];
        
        //Find beginning of profile picture URL
        cruftRange = [currentRow rangeOfString:@"src=\""];
        currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
        //Find end of profile picture URL
        cruftRange = [currentRow rangeOfString:@"\""];
        //Extract the profile picture URL
        NSString *profilePictureURL = [currentRow substringWithRange:NSMakeRange(0, cruftRange.location)];
        
        //Find the range of the starting markup
        cruftRange = [currentRow rangeOfString:@"<td class=\"cell c1\"><strong><a href"];
        //Trim the current row
        currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
        //Identify the start and end locations of the participant's name
        int nameStart = [currentRow rangeOfString:@">"].location;
        int nameEnd = [currentRow rangeOfString:@"<"].location;
        //Pull out the name
        NSString *name = [currentRow substringWithRange:NSMakeRange(nameStart + 1, nameEnd - nameStart - 1)];
        
        //Trim to the beginning of the city (next data item)
        currentRow = [currentRow substringFromIndex:nameEnd];
        cruftRange = [currentRow rangeOfString:@"</a></strong></td><td class=\"cell c2\">"];
        currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
        int cityEnd = [currentRow rangeOfString:@"<"].location;
        NSString *city = [currentRow substringWithRange:NSMakeRange(0, cityEnd)];
        
        //Extract the country
        cruftRange = [currentRow rangeOfString:@"</td><td class=\"cell c3\">"];
        currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
        int countryEnd = [currentRow rangeOfString:@"<"].location;
        NSString *country = [currentRow substringWithRange:NSMakeRange(0, countryEnd)];
        
      /*  //Extract the date the participant last accessed GauchoSpace
        cruftRange = [currentRow rangeOfString:@"<td class=\"cell c4\">"];
        currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
        int lastAccessEnd = [currentRow rangeOfString:@"<"].location;
        NSString *lastAccessed = [currentRow substringWithRange:NSMakeRange(0, lastAccessEnd)];*/

        BOOL inAddressBook = NO;
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
        
        if (addressBook) {
            CFArrayRef matches = ABAddressBookCopyPeopleWithName(addressBook, (CFStringRef)name);
            if (CFArrayGetCount(matches) != 0)
                inAddressBook = YES;
            
            CFRelease(addressBook);
            CFRelease(matches);
        }
        
        //Create a participant object to model this participant
        GMParticipant *participant = [[GMParticipant alloc] init];
        participant.name = name;
        participant.city = city;
        participant.country = country;
        participant.userID = [userID integerValue];
        participant.imageURL = [NSURL URLWithString:[profilePictureURL stringByReplacingOccurrencesOfString:@"f2" withString:@"f1"]];
       // participant.lastAccess = [self dateFromAccessTimestamp:lastAccessed];
        participant.inAddressBook = inAddressBook;
    
        //Add the participant to the array of all participants
        [participants addObject:participant];
        
        [participant release];
    }
    
    return participants;
}

- (NSDate *)dateFromAccessTimestamp:(NSString *)timeStamp {
    if ([timeStamp isEqualToString:@"Never"]) {
        return nil;
    }
    else if ([timeStamp isEqualToString:@"now"]) {
        return [NSDate date];
    }
    else {
        NSArray *components = [timeStamp componentsSeparatedByString:@" "];
        
        NSString *currentComponent = nil;
        int lastNumber = 0;
        int totalSeconds = 0;
        
        for (int i = 0; i < [components count]; i++) {
            
            currentComponent = [components objectAtIndex:i];
            
            if (i % 2 == 0) { //This is a numerical value
                lastNumber = [currentComponent intValue];
            }
            else { //This is a word (days, mins, secs, etc.)
                if ([currentComponent hasPrefix:@"day"])
                    totalSeconds += lastNumber * 86400;
                else if ([currentComponent hasPrefix:@"hour"])
                    totalSeconds += lastNumber * 3600;
                else if ([currentComponent hasPrefix:@"min"])
                    totalSeconds += lastNumber * 60;
                else if ([currentComponent hasPrefix:@"sec"])
                    totalSeconds += lastNumber;
            }
        }
        
        NSDate *date = [[NSDate date] dateByAddingTimeInterval:(totalSeconds * -1)];
        return date;
    }
}

@end
