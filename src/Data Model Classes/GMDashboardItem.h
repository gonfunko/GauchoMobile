//
//  GMDashboardItem.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GMDashboardItem : NSObject {
@private
    NSString *dateRange;
    NSString *contents;
    NSArray *links;
}

@property (copy) NSString *dateRange;
@property (copy) NSString *contents;
@property (retain) NSArray *links;

@end
