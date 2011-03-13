//
// GMAssignment.h
// Models an assignment on GauchoSpace
// Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>

@interface GMAssignment : NSObject <NSCoding> {
@private
  NSString *description;
  NSDate *dueDate;
  NSDate *submittedDate;
  NSInteger assignmentID;
}

@property (copy) NSString *description;
@property (copy) NSDate *dueDate;
@property (copy) NSDate *submittedDate;
@property (assign) NSInteger assignmentID;

//Returns true if the receiver is equal to object, otherwise returns false
- (BOOL)isEqualTo:(id)object;

@end
