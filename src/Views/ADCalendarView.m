//
//  ADCalView.m
//  CalTest
//
//  Created by Aaron Dodson on 3/16/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "ADCalendarView.h"

@implementation ADCalendarView

@synthesize baseDate;
@synthesize dataSource;
@synthesize delegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        dayTiles = [[NSMutableArray alloc] init];
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit)
                                                       fromDate:[NSDate date]];
        
        //Add a month to our current base date
        self.baseDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        [self layOutDayTiles];
        
        UIButton *previousMonth = [UIButton buttonWithType:UIButtonTypeCustom];
        previousMonth.frame = CGRectMake(15, 5, 30, 30);
        [previousMonth setImage:[UIImage imageNamed:@"greyback.png"] forState:UIControlStateNormal];
        [previousMonth addTarget:self action:@selector(loadPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:previousMonth];
        
        UIButton *nextMonth = [UIButton buttonWithType:UIButtonTypeCustom];
        nextMonth.frame = CGRectMake(self.frame.size.width - 45, 5, 30, 30);
        [nextMonth setImage:[UIImage imageNamed:@"greyforward.png"] forState:UIControlStateNormal];
        [nextMonth addTarget:self action:@selector(loadNextMonth) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextMonth];
        
        NSInteger leftOffset = 5;
        NSInteger availableWidth = self.frame.size.width - 80;
        NSInteger tileWidth = availableWidth / 7;
        NSArray *days = [NSArray arrayWithObjects:@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", nil];
        
        for (NSString *day in days) {
            CATextLayer *dayLayer = [CATextLayer layer];
            dayLayer.string = day;
            dayLayer.fontSize = 12.0;
            dayLayer.foregroundColor = [[UIColor lightGrayColor] CGColor];
            dayLayer.font = @"Helvetica";
            dayLayer.alignmentMode = kCAAlignmentRight;
            dayLayer.frame = CGRectMake(leftOffset, 45, tileWidth, 18);
            dayLayer.contentsScale = [[UIScreen mainScreen] scale];
            [self.layer addSublayer:dayLayer];
            leftOffset += tileWidth + 10;
        }
    }
    
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    for (CATextLayer *day in dayTiles) {
        if (CGRectContainsPoint(day.frame, touchPoint)) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
                                                           fromDate:self.baseDate];
            
            dateComponents.day = [day.string intValue];
            [dateComponents setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            [self.delegate calendarMonthView:nil didSelectDate:[calendar dateFromComponents:dateComponents]];
        }
    }
}

- (void)loadPreviousMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) 
                                                   fromDate:self.baseDate];
    
    //Subtract a month from our current base date
    dateComponents.month = dateComponents.month - 1;

    //Update it
    self.baseDate = [calendar dateFromComponents:dateComponents];
    
    //Lay out our day tiles
    [self layOutDayTiles];
}

- (void)loadNextMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) 
                                                   fromDate:self.baseDate];
    
    //Add a month to our current base date
    dateComponents.month = dateComponents.month + 1;
    self.baseDate = [calendar dateFromComponents:dateComponents];
    
    //Lay out our day tiles
    [self layOutDayTiles];
}

- (void)reloadData {
    [self layOutDayTiles];
}

- (void)layOutDayTiles {
    //Calculate some dimensions
    NSInteger availableWidth = self.frame.size.width - 80;
    NSInteger tileWidth = availableWidth / 7;
    NSInteger leftOffset = 5;
    NSInteger topOffet = 70;
    
    //Snag the date components from our base date...
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit) 
                                                   fromDate:self.baseDate];
    //And the present date
    NSDateComponents *todayDateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
                                                        fromDate:[NSDate date]];

    //Reset the base date components to be the first of the month
    dateComponents.day = 1;
    
    NSDate *currentDate = [calendar dateFromComponents:dateComponents];
    
    NSArray *months = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
    if (title == nil) {
        title = [CATextLayer layer];
    }
    
    //Set the title to be Month Year
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    title.string = [NSString stringWithFormat:@"%@ %d", [months objectAtIndex:dateComponents.month - 1], dateComponents.year];
    [CATransaction commit];
    title.fontSize = 24.0;
    title.foregroundColor = [[UIColor lightGrayColor] CGColor];
    title.font = @"Helvetica-Bold";
    title.alignmentMode = kCAAlignmentCenter;
    title.frame = CGRectMake(0, 5, self.frame.size.width, 30.0);
    title.contentsScale = [[UIScreen mainScreen] scale];
    [self.layer addSublayer:title];
       
    
    //Get the date components for the first of the month
    NSDateComponents *firstDayComponents = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:currentDate];
    //Figure out what word-style day the first was/is, and offset the first row of dates in the calendar appropriately
    leftOffset = (tileWidth + 10) * (firstDayComponents.weekday - 1) + 5;
    
    //Clear all the tiles, in case we're moving to a new month
    for (CATextLayer *layer in dayTiles) {
        [layer removeFromSuperlayer];
    }
    
    [dayTiles removeAllObjects];
    
    NSDateComponents *lastDayComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:currentDate]; // Get necessary date components
    // set last of month
    [lastDayComponents setMonth:[lastDayComponents month]+1];
    [lastDayComponents setDay:0];
    NSDate *lastDay = [calendar dateFromComponents:lastDayComponents];
    
    NSArray *markedDays = [[self.dataSource calendarMonthView:nil marksFromDate:currentDate toDate:lastDay] retain];
    
    //Keep going as long as the current day is in the same month
    while ([calendar components:NSMonthCalendarUnit fromDate:currentDate].month == dateComponents.month) {
        //Pull the date components from the current date
        NSDateComponents *currentDateComponents = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:currentDate];
        
        //Create a new tile with the appropriate date info
        CATextLayer *dayLayer = [CATextLayer layer];
        dayLayer.string = [NSString stringWithFormat:@"%i", currentDateComponents.day];
        dayLayer.fontSize = 18.0;
        if ([[markedDays objectAtIndex:MAX(currentDateComponents.day - 2, 0)] boolValue]) {
            dayLayer.font = @"Helvetica-Bold";
            dayLayer.foregroundColor = [[UIColor grayColor] CGColor];
        } else {
            dayLayer.font = @"Helvetica";
            dayLayer.foregroundColor = [[UIColor lightGrayColor] CGColor];
        }
        dayLayer.alignmentMode = kCAAlignmentRight;
        dayLayer.cornerRadius = 3.0;
        dayLayer.frame = CGRectMake(leftOffset, topOffet, tileWidth, 25);
        dayLayer.contentsScale = [[UIScreen mainScreen] scale];
        
        //If the current day is actually today, make it bold and blue
        if (currentDateComponents.day == todayDateComponents.day &&
            currentDateComponents.month == todayDateComponents.month &&
            currentDateComponents.year == todayDateComponents.year) {
            dayLayer.foregroundColor = [[UIColor colorWithRed:59/255.0 green:114/255.0 blue:240/255.0 alpha:1.0] CGColor];
            dayLayer.font = @"Helvetica-Bold";
        }
        
        //Add the tile to the view and array of tiles
        [self.layer addSublayer:dayLayer];
        [dayTiles addObject:dayLayer];
        
        //Update left offset
        leftOffset += tileWidth + 10;
        
        //If we're on Saturday, reset the top and left offsets for the next row of dates
        if (currentDateComponents.weekday == 7) { //Saturday
            topOffet += 35;
            leftOffset = 5;
        }
        
        currentDateComponents.day = currentDateComponents.day + 1;
        currentDate = [calendar dateFromComponents:currentDateComponents];
    }
    
    [markedDays release];
}

- (void)dealloc {
    [dayTiles release];
    self.baseDate = nil;
    [super dealloc];
}

@end
