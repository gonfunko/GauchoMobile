//
//  GMWeekView.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GMWeekView : UIView {
    NSMutableArray *dayLayers;
    CALayer *back, *forward;
    CATextLayer *title;
    
    int weekOffset;
    id delegate;
}

@property (assign) id delegate;

- (NSDate *)beginningOfWeek;
- (void)updateDates;

@end
