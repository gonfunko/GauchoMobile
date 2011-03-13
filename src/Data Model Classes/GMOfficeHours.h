//
// GMOfficeHours.h
// Models an office hours appointment
// Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>


@interface GMOfficeHours : NSObject <NSCoding> {
@private
    NSString *day;
    NSDate *time;
}

@property (copy) NSString *day;
@property (copy) NSDate *time;

//Returns true if the receiver is equal to object, otherwise false
- (BOOL)isEqualTo:(id)object;

@end
