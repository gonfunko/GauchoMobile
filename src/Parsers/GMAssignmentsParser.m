//
// GMAssignmentsParser.m
// Parses the GauchoSpace Assignments page and returns an array of GMAssignment objects.
// Created by Group J5 for CS48
//

#import "GMAssignmentsParser.h"


@implementation GMAssignmentsParser

- (NSArray *)assignmentsFromSource:(NSString *)source {
    
    NSMutableArray *assignments = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray *tables = [source componentsSeparatedByString:@"<table"];
    NSArray *rows = [[tables objectAtIndex:1] componentsSeparatedByString:@"<tr"];
    
    for (int i = 2; i < [rows count]; i++) {
        NSString *currentRow = [rows objectAtIndex:i];
        
        if ([currentRow rangeOfString:@"tabledivider"].location == NSNotFound) {
            NSRange cruftRange = [currentRow rangeOfString:@"view.php?id="];
            currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
            int idEnd = [currentRow rangeOfString:@"\""].location;
            int assignmentID = (int)[[currentRow substringToIndex:idEnd] floatValue];
            
            NSString *description = [currentRow substringWithRange:NSMakeRange([currentRow rangeOfString:@">"].location + 1, [currentRow rangeOfString:@"<"].location - [currentRow rangeOfString:@">"].location - 1)];
            
            cruftRange = [currentRow rangeOfString:@"class=\"cell c3\">"];
            currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
            int dueDateEnd = [currentRow rangeOfString:@"<"].location;
            NSString *dueDate = [currentRow substringToIndex:dueDateEnd];
            
            NSString *submitDate = @"";
            if ([currentRow rangeOfString:@"<span class=\"early\">"].location != NSNotFound)
                cruftRange = [currentRow rangeOfString:@"<span class=\"early\">"];
            else if ([currentRow rangeOfString:@"<span class=\"late\">"].location != NSNotFound)
                cruftRange = [currentRow rangeOfString:@"<span class=\"late\">"];
            else
                cruftRange = [currentRow rangeOfString:@"class=\"cell c4\">"];
            
            currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
            int submitDateEnd = [currentRow rangeOfString:@"<"].location;
            submitDate = [currentRow substringToIndex:submitDateEnd];
            
            NSDate *submissionDate = nil;
            NSDate *assignmentDueDate = nil;
            if (![submitDate isEqualToString:@""])
                submissionDate = [self dateFromDateString:submitDate];
            if (![dueDate isEqualToString:@"-"])
                assignmentDueDate = [self dateFromDateString:dueDate];

            
            GMAssignment *assignment = [[GMAssignment alloc] init];
            assignment.assignmentID = assignmentID;
            assignment.description = [description gtm_stringByUnescapingFromHTML];
            assignment.dueDate = assignmentDueDate;
            assignment.submittedDate = submissionDate;
            
            [assignments addObject:assignment];
            
            [assignment release];
        }
    }
    
    return assignments;
}

- (NSDate *)dateFromDateString:(NSString *)dateString {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, d MMMM yyyy, hh:mm a"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDate *date = [formatter dateFromString:dateString];
    [formatter release];
    
    return date;
}

@end
