//
//  GMCourseParser.h
//  Parses the GauchoSpace Courses page and returns an array of GMCourse objects.
//  Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>
#import "GMCourse.h"

@interface GMCourseParser : NSObject {
@private
    
}

//Returns an array of GMCourse objects given the HTML source of the GauchoSpace courses page
//May raise an NSRangeException if given malformed input
- (NSArray *)coursesFromSource:(NSString *)source;

//Returns the name of a course from the GauchoSpace description, eg
//passing CMPSC 56 (100) - ADV APP PROGRAM - Winter 2011 as description returns CMPSC 56
//May raise an NSRangeException if given malformed input
- (NSString *)courseNameFromDescription:(NSString *)description;

//Returns a GMQuarter object representing the quarter the course is offered in from the GauchoSpace description, eg
//passing CMPSC 56 (100) - ADV APP PROGRAM - Winter 2011 as description returns a GMQuarter representing Winter 2011
//May raise an NSRangeException if given malformed input
- (GMQuarter *)quarterFromDescription:(NSString *)description;

@end
