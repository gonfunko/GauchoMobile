//
//  ADCalView.h
//  CalTest
//
//  Created by Aaron Dodson on 3/16/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TKCalendarMonthView.h"

@interface ADCalendarView : UIView {
    NSDate *baseDate;
    NSMutableArray *dayTiles;
    CATextLayer *title;
    __unsafe_unretained id <TKCalendarMonthViewDataSource> dataSource;
    __unsafe_unretained id <TKCalendarMonthViewDelegate> delegate;
}

@property (copy) NSDate *baseDate;
@property (assign) id <TKCalendarMonthViewDataSource> dataSource;
@property (assign) id <TKCalendarMonthViewDelegate> delegate;

- (void)reloadData;

@end
