//
// GMGradesParser.m
// Parses the GauchoSpace Grades page and returns an array of GMGrade objects.
// Created by Group J5 for CS48
//

#import "GMGradesParser.h"


@implementation GMGradesParser

- (NSArray *)gradesFromSource:(NSString *)source {
    
    NSMutableArray *grades = [[[NSMutableArray alloc] init] autorelease];
    
    //Separate all the tables
	NSArray *tables = [source componentsSeparatedByString:@"<table"];
    
    NSArray *rows = [[tables objectAtIndex:1] componentsSeparatedByString:@"<tr"];
    
    for (int i = 0; i < [rows count]; i++) {
        
        int gradeID = 0;
        int score = 0;
        int max = 0;
        NSString *description = nil;
        NSString *feedback = nil;
        
        
        NSString *currentRow = [rows objectAtIndex:i];
        
        if ([currentRow rangeOfString:@"<td class='  item b1b' colspan='"].location != NSNotFound) {
            
            if ([currentRow rangeOfString:@"grade.php?id="].location != NSNotFound) {
                NSString *temp = currentRow;
                NSRange cruftRange = [temp rangeOfString:@"grade.php?id="];
                temp = [temp substringFromIndex:cruftRange.location + cruftRange.length];
                cruftRange = [temp rangeOfString:@"\""];
                gradeID = (int)[[temp substringToIndex:cruftRange.location] floatValue];
            }
            
            NSRange cruftRange = [currentRow rangeOfString:@"\"/>"];
            currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
            int descriptionEnd = [currentRow rangeOfString:@"<"].location;
            description = [currentRow substringWithRange:NSMakeRange(0, descriptionEnd)];
            
            NSMutableArray *gradeInformation = [[NSMutableArray alloc] init];
            
            for (int j = 0; j < 3; j++) {
                cruftRange = [currentRow rangeOfString:@"<td class='  item b1b' >"];
                currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
                int end = [currentRow rangeOfString:@"<"].location;
                NSString *item = [currentRow substringWithRange:NSMakeRange(0, end)];
                
                [gradeInformation addObject:item];
            }
            
            if ([gradeInformation count] != 0) {
                score = [self numericalScoreFromScoreDescription:[gradeInformation objectAtIndex:0]];
            } else {
                score = -1;
            }
            
            if ([gradeInformation count] >= 2) {
                max = [self maxValueFromRange:[gradeInformation objectAtIndex:1]];
            }
            
            /* If there's a third column and it has a percent sign in it, use its value to determine the score
               Normally we use the first column ("Grade") in the first if above, but sometimes that contains letter grades instead of a numeric score
               We use its value by default, but if there's a % in this column, that strongly implies it also contains a number, so we'll use it instead
            */
            if ([gradeInformation count] > 2 && [[gradeInformation objectAtIndex:2] rangeOfString:@"%"].location != NSNotFound && score == -1) {
                score = [self numericalScoreFromScoreDescription:[gradeInformation objectAtIndex:2]];
            }
            
            if ([currentRow rangeOfString:@"<td class='  item b1b feedbacktext' >"].location != NSNotFound) {
                cruftRange = [currentRow rangeOfString:@"<td class='  item b1b feedbacktext' >"];
                currentRow = [currentRow substringFromIndex:cruftRange.location + cruftRange.length];
                int feedbackEnd = [currentRow rangeOfString:@"<"].location;
                feedback = [currentRow substringToIndex:feedbackEnd];
                if ([feedback isEqualToString:@"&nbsp;"])
                    feedback = @"";
            }
            
            GMGrade *grade = [[GMGrade alloc] init];
            grade.description = [description gtm_stringByUnescapingFromHTML];
            grade.score = (NSInteger)score;
            grade.max = (NSInteger)max;
            grade.feedback = feedback;
            grade.gradeID = gradeID;
            
            [grades addObject:grade];
            [gradeInformation release];
            [grade release];
        }
    }
    
    return grades;
}

- (int)numericalScoreFromScoreDescription:(NSString *)description {
    if ([description isEqualToString:@"-"]
        || [description hasPrefix:@"A"]
        || [description hasPrefix:@"B"]
        || [description hasPrefix:@"C"]
        || [description hasPrefix:@"D"]
        || [description hasPrefix:@"F"])
        return -1;
    else if ([description rangeOfString:@" "].location != NSNotFound) {
        int score = (int)[[description substringToIndex:[description rangeOfString:@" "].location] floatValue];
        return score;
    } else {
        int score = (int)[description floatValue];
        return score;
    }
}

- (int)maxValueFromRange:(NSString *)range {
    
    int max;
    
    if ([range rangeOfString:@"–"].location != NSNotFound) {
        range = [range substringFromIndex:[range rangeOfString:@"–"].location + 1];
        max = (int)[range floatValue];
    } else {
        max = (int)[[range substringFromIndex:[range rangeOfString:@";"].location + 1] floatValue];
    }
    
    return max;
}

@end
