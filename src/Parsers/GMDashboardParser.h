//
//  GMDashboardParser.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMDashboardItem.h"
#import "GTMNSString+HTML.h"

@interface GMDashboardParser : NSObject {
@private
    
}

//Returns an array of GMDashboardItem objects given the HTML source of the GauchoSpace course dashboard page
//May raise an NSRangeException if given malformed input
- (NSArray *)dashboardItemsFromSource:(NSString *)source;

//Removes HTML tags from a given string and replaces ampersands and dashes with their textual versions
- (NSString *)stripHTMLFromString:(NSString *)source;

@end
