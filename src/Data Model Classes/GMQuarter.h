//
// GMQuarter.h
// Models an academic quarter
// Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>


@interface GMQuarter : NSObject <NSCoding> {
@private
    NSInteger year;
    NSString *quarter;
}

@property (assign) NSInteger year;
@property (copy) NSString *quarter;

//Returns a description of the quarter as an NSString, eg Winter 2011
- (NSString *)description;

//Returns true if the receiver is equal to object, otherwise returns false
- (BOOL)isEqualTo:(id)object;

@end
