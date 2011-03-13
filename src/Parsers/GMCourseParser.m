//
//  GMCourseParser.m
//  Parses the GauchoSpace Courses page and returns an array of GMCourse objects.
//  Created by Group J5 for CS48
//

#import "GMCourseParser.h"


@implementation GMCourseParser

- (NSArray *)coursesFromSource:(NSString *)source {
    
    NSMutableArray *courses = [[NSMutableArray alloc] init];
    
    NSRange cruftRange;
    
    while ([source rangeOfString:@"Click to enter this course\" href=\"https://gauchospace.ucsb.edu/courses/course/view.php?id="].location != NSNotFound) {
        cruftRange = [source rangeOfString:@"Click to enter this course\" href=\"https://gauchospace.ucsb.edu/courses/course/view.php?id="];
    
        source = [source substringFromIndex:cruftRange.location + cruftRange.length];
        
        int courseIDEnd = [source rangeOfString:@"\""].location;
        int courseID = [[source substringToIndex:courseIDEnd] intValue];
    
        cruftRange = [source rangeOfString:@">"];
        source = [source substringFromIndex:cruftRange.location + 1];
        int courseEnd = [source rangeOfString:@"<"].location;
        NSString *courseDescription = [source substringToIndex:courseEnd];
        
        GMCourse *course = [[GMCourse alloc] init];
        course.name = [self courseNameFromDescription:courseDescription];
        course.quarter = [self quarterFromDescription:courseDescription];
        course.courseID = (NSInteger)courseID;
        
        [courses addObject:course];
        [course release];
    }
    return [courses autorelease];
}

- (NSString *)courseNameFromDescription:(NSString *)description {
    if ([description rangeOfString:@" ("].location != NSNotFound) {
    NSRange cruftRange = [description rangeOfString:@" ("];
    return [description substringToIndex:cruftRange.location];
    }
    else
        return description;
}

- (GMQuarter *)quarterFromDescription:(NSString *)description {
    if ([description rangeOfString:@" - "].location != NSNotFound) {
    NSRange cruftRange = [description rangeOfString:@" - "];
    description = [description substringFromIndex:cruftRange.location + cruftRange.length];
    cruftRange = [description rangeOfString:@" - "];
    description = [description substringFromIndex:cruftRange.location + cruftRange.length];
    
    int quarterEnd = [description rangeOfString:@" "].location;
    NSString *quarter = [description substringToIndex:quarterEnd];
    
    description = [description substringFromIndex:quarterEnd + 1];
    
    int year = [description intValue];
    
    GMQuarter *newQuarter = [[[GMQuarter alloc] init] autorelease];
    newQuarter.quarter = quarter;
    newQuarter.year = year;
    
    return newQuarter;
    }
    else
        return [[[GMQuarter alloc] init] autorelease];
}

@end
