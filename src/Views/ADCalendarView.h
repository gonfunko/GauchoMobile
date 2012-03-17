//
//  ADCalView.h
//  CalTest
//
//  Created by Aaron Dodson on 3/16/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ADCalendarView : UIView {
    NSDate *baseDate;
    NSMutableArray *dayTiles;
    CATextLayer *title;
}

@property (copy) NSDate *baseDate;

@end
