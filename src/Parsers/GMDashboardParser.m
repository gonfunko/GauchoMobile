//
//  GMDashboardParser.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GMDashboardParser.h"


@implementation GMDashboardParser

- (NSArray *)dashboardItemsFromSource:(NSString *)source {
    NSMutableArray *dashboardItems = [[[NSMutableArray alloc] init] autorelease];
    
    //If the user is not enrolled in any courses, we may not actually be passed the source for a dashboard page; if so, bail out
    if ([source rangeOfString:@"class=\"summary\">"].location == NSNotFound) {
        return dashboardItems;
    }
    
    NSArray *items = [source componentsSeparatedByString:@"class=\"weekdates\">"];
    
    for (int i = 0; i < [items count]; i++) {
        NSString *currentItem = [items objectAtIndex:i];
        NSString *dateRange = [[[currentItem substringToIndex:[currentItem rangeOfString:@"<"].location] stringByReplacingOccurrencesOfString:@"   " withString:@" "] stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        
        if ([currentItem rangeOfString:@"CDATA"].location != NSNotFound && i != 0)
            currentItem = [currentItem substringToIndex:[currentItem rangeOfString:@"CDATA"].location];
        
        currentItem = [currentItem substringFromIndex:[currentItem rangeOfString:@"class=\"summary\">"].location + 16];
        
        NSString *content = [self stripHTMLFromString:[currentItem substringToIndex:[currentItem rangeOfString:@"</div>"].location]];
        content = [self removeXMLEntitiesFromString:content];
        
        if ([content length] < 2) {
            if ([currentItem rangeOfString:@"</li>"].location != NSNotFound && i != [items count] - 1) {
                content = [self stripHTMLFromString:[currentItem substringToIndex:[currentItem rangeOfString:@"</li>"].location]];
                content = [self removeXMLEntitiesFromString:content];
            }
        }
        
        NSArray *links = [currentItem componentsSeparatedByString:@"<li class="];
        
        NSMutableArray *allLinks = [NSMutableArray array];
        
        if ([links count] > 1) {
            for (int j = 1; j < [links count]; j++) {
                NSString *currentLink = [links objectAtIndex:j];
                
                if ([currentLink rangeOfString:@"<span>"].location != NSNotFound &&
                    [currentLink rangeOfString:@"href=\""].location != NSNotFound) {
                    currentLink = [currentLink substringFromIndex:[currentLink rangeOfString:@"href=\""].location + 6];
                    
                    NSString *url = [currentLink substringToIndex:[currentLink rangeOfString:@"\""].location];
                    
                    currentLink = [currentLink substringFromIndex:[currentLink rangeOfString:@"<span>"].location + 6];
                    NSString *title = [currentLink substringToIndex:[currentLink rangeOfString:@"<"].location];
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", url, @"url", nil];
                    [allLinks addObject:dict];
                }
            }
        }
        
        GMDashboardItem *newItem = [[GMDashboardItem alloc] init];
        newItem.contents = content;
        newItem.dateRange = dateRange;
        newItem.links = allLinks;
        [dashboardItems addObject:newItem];
        [newItem release];
    }
    
    return dashboardItems;
    
}

- (NSString *)stripHTMLFromString:(NSString *)source {
    //Based on http://stackoverflow.com/questions/277055/remove-html-tags-from-an-nsstring-on-the-iphone
    source = [source stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    source = [source stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"–"];
    source = [source stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    source = [source stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
    NSRange r;
    while ((r = [source rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        source = [source stringByReplacingCharactersInRange:r withString:@""];
    }
    
    source = [source stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return source;
}

//From http://stackoverflow.com/questions/1105169/html-character-decoding-in-objective-c-cocoa-touch
- (NSString *)removeXMLEntitiesFromString:(NSString *)string {
    NSUInteger myLength = [string length];
    NSUInteger ampIndex = [string rangeOfString:@"&" options:NSLiteralSearch].location;
    
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return string;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
    
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    [scanner setCharactersToBeSkipped:nil];
    
    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];
    
    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            
            if (gotNumber) {
                [result appendFormat:@"%u", charCode];
                
                [scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";
                
                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];
                
                
                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];
                
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
                
            }
            
        }
        else {
            NSString *amp;
            
            [scanner scanString:@"&" intoString:&amp];      //an isolated & symbol
            [result appendString:amp];
        }
        
    }
    while (![scanner isAtEnd]);
    
finish:
    return result;
}

@end
