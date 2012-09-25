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
        
        if ([content length] < 2) {
            if ([currentItem rangeOfString:@"</li>"].location != NSNotFound && i != [items count] - 1) {
                content = [self stripHTMLFromString:[currentItem substringToIndex:[currentItem rangeOfString:@"</li>"].location]]; 
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

@end
