//
// GMAssignmentsParser.h
// Parses the GauchoSpace Assignments page and returns an array of GMAssignment objects.
// Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>
#import "GMAssignment.h"

@interface GMAssignmentsParser : NSObject {
@private
    
}

//Returns an array of GMAssignment objects given the HTML source of a GauchoSpace assignment page
//May raise an NSRangeException if given malformed input
- (NSArray *)assignmentsFromSource:(NSString *)source;

//Returns an NSDate object given a string of the format on the GauchoSpace assignments page
- (NSDate *)dateFromDateString:(NSString *)dateString;

@end
