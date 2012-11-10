//
//  GMAssignmentDetailsParser.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 1/14/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMAssignmentDetailsParser.h"

@implementation GMAssignmentDetailsParser

- (NSDictionary *)assignmentDetailsFromSource:(NSString *)html {
    html = [html substringFromIndex:[html rangeOfString:@"<div id=\"intro\" class=\"box generalbox generalboxcontent boxaligncenter\">"].location + 72];
    NSString *result = [[html substringToIndex:[html rangeOfString:@"</div>"].location] gtm_stringByUnescapingFromHTML];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:result, @"details", nil];
    
    return dict;
}

@end