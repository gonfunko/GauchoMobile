//
//  GMAssignmentDetailsParser.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 1/14/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMAssignmentDetailsParser : NSObject

- (NSDictionary *)assignmentDetailsFromSource:(NSString *)html;

@end
