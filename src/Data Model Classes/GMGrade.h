//
// GMGrade.h
// Models a grade on GauchoSpace
// Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>
#import "GMAssignment.h"

@interface GMGrade : NSObject <NSCoding> {
@private
    NSString *description;
    NSInteger score;
    NSInteger max;
    NSInteger gradeID;
    NSString *feedback;
}

@property (copy) NSString *description;
@property (assign) NSInteger score;
@property (assign) NSInteger max;
@property (copy) NSString *feedback;
@property (assign) NSInteger gradeID;

//Returns true if the receiver is equal to object, otherwise returns false
- (BOOL)isEqualTo:(id)object;

@end
