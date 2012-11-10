//
// GMGradesParser.h
// Parses the GauchoSpace Grades page and returns an array of GMGrade objects.
// Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>
#import "GMGrade.h"
#import "GTMNSString+HTML.h"

@interface GMGradesParser : NSObject {
@private
    
}

//Returns an array of GMGrade objects given valid HTML source for the GauchoSpace grades page
//May raise an NSRangeException if given malformed input
- (NSArray *)gradesFromSource:(NSString *)source;

//Returns an int corresponding to the score on an assignment whose grade range is passed as description in
//the GauchoSpace format; if ungraded, returns -1; given malformed input, may raise an NSRangeException or return 0
- (int)numericalScoreFromScoreDescription:(NSString *)description;

//Returns an int corresponding to the maximum possible score on an assignment whose grade range is passed as range in
//the GauchoSpace format; given malformed input, may raise an NSRangeException or return 0
- (int)maxValueFromRange:(NSString *)range;

@end
