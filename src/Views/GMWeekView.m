//
//  GMWeekView.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GMWeekView.h"

@implementation GMWeekView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        dayLayers = [[NSMutableArray alloc] init];
        weekOffset = 0;
        
        CAGradientLayer *titleBar = [CAGradientLayer layer];
        CGColorRef first = [[UIColor colorWithRed:246/255.0 green:246/255.0 blue:247/255.0 alpha:1.0] CGColor];
        CGColorRef second = [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:209/255.0 alpha:1.0] CGColor];
        titleBar.colors = [NSArray arrayWithObjects:(id)first, (id)second, nil];
        titleBar.frame = CGRectMake(-1, 0, frame.size.width + 2, 60);
        titleBar.borderColor = [[UIColor darkGrayColor] CGColor];
        titleBar.borderWidth = 1.0;
        titleBar.shouldRasterize = YES;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM YYYY"];
        title = [CATextLayer layer];
        title.string = [formatter stringFromDate:[NSDate date]];
        [formatter release];
        title.foregroundColor = [[UIColor colorWithRed:59/255.0 green:73/255.0 blue:88/255.0 alpha:1.0] CGColor];
        title.alignmentMode = kCAAlignmentCenter;
        title.frame = CGRectMake(0, 10, frame.size.width, [title preferredFrameSize].height);
        title.fontSize = 22.0;
        title.font = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica-Bold" size:18.0].fontName);
        title.shouldRasterize = YES;
        [titleBar addSublayer:title];
        
        back = [CALayer layer];
        back.contents = (id)[[UIImage imageNamed:@"Month Calendar Left Arrow@2x.png"] CGImage];
        back.frame = CGRectMake(10, 10, 20, 24);
        back.shouldRasterize = YES;
        [back setValue:@"back" forKey:@"name"];
        [titleBar addSublayer:back];
        
        forward = [CALayer layer];
        forward.contents = (id)[[UIImage imageNamed:@"Month Calendar Right Arrow@2x.png"] CGImage];
        forward.frame = CGRectMake(frame.size.width - 30, 10, 20, 24);
        forward.shouldRasterize = YES;
        [forward setValue:@"forward" forKey:@"name"];
        [titleBar addSublayer:forward];
        
        double width = frame.size.width / 7.0;
        NSArray *days = [NSArray arrayWithObjects:@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", nil];
        NSDate *currentDay = [self beginningOfWeek];
        
        CALayer *base = [CALayer layer];
        base.frame = CGRectMake(-3, 0, frame.size.width + 6, 60 + width);
        base.backgroundColor = [[UIColor whiteColor] CGColor];
        base.shadowColor = [[UIColor blackColor] CGColor];
        base.shadowOpacity = 0.5;
        base.shadowRadius = 6.0;
        base.shadowOffset = CGSizeMake(0, 6);
        base.shouldRasterize = YES;
        [self.layer addSublayer:base];
        
        for (int i = 0; i < 7; i++) {
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:currentDay];
            NSDateComponents *today = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date]];
            
            CALayer *day = [CALayer layer];
            day.borderWidth = 0.5;
            day.borderColor = [[UIColor darkGrayColor] CGColor];
            day.frame = CGRectMake(i * width, 60, width, MIN(frame.size.height - 60, width));
            day.shouldRasterize = YES;
            [day setValue:currentDay forKey:@"date"];
            
            CATextLayer *dayLabel = [CATextLayer layer];
            dayLabel.string = [NSString stringWithFormat:@"%ld", (long)[components day]];
            dayLabel.fontSize = 40.0;
            dayLabel.font = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica-Bold" size:40.0].fontName);
            dayLabel.alignmentMode = kCAAlignmentCenter;
            dayLabel.frame = CGRectMake(0, (int)((day.frame.size.height - [dayLabel preferredFrameSize].height) / 2), (int)width, (int)[dayLabel preferredFrameSize].height);
            dayLabel.shouldRasterize = YES;
            
            CATextLayer *dayTitle = [CATextLayer layer];
            dayTitle.string = [days objectAtIndex:i];
            dayTitle.fontSize = 12.0;
            dayTitle.font = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica" size:12.0].fontName);
            dayTitle.foregroundColor = [[UIColor colorWithRed:59/255.0 green:73/255.0 blue:88/255.0 alpha:1.0] CGColor];
            dayTitle.alignmentMode = kCAAlignmentCenter;
            dayTitle.shadowColor = [[UIColor whiteColor] CGColor];
            dayTitle.shadowOffset = CGSizeMake(0, 1);
            dayTitle.shadowOpacity = 1.0;
            dayTitle.shadowRadius = 0.0;
            dayTitle.frame = CGRectMake((int)(i * width), (int)(60 - [dayTitle preferredFrameSize].height - 3), width, [dayTitle preferredFrameSize].height);
            dayTitle.shouldRasterize = YES;
            [titleBar addSublayer:dayTitle];
            
            if (i == 0 || i == 6) {
                day.backgroundColor = [[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0] CGColor];
                dayLabel.foregroundColor = [[UIColor grayColor] CGColor];
            } else if ([components day] == [today day]) {
                day.backgroundColor = [[UIColor colorWithRed:227/255.0 green:234/255.0 blue:246/255.0 alpha:1.0] CGColor];
                dayLabel.foregroundColor = [[UIColor colorWithRed:41/255.0 green:121/255.0 blue:242/255.0 alpha:1.0] CGColor];
            } else {
                day.backgroundColor = [[UIColor whiteColor] CGColor];
                dayLabel.foregroundColor = [[UIColor grayColor] CGColor];
            }
            
            if (i == 6) {
                day.frame = CGRectMake(day.frame.origin.x, day.frame.origin.y, day.frame.size.width + 1, day.frame.size.height);
            }
            
            [day addSublayer:dayLabel];
            [self.layer addSublayer:day];
            [dayLayers addObject:day];
            
            currentDay = [currentDay dateByAddingTimeInterval:86400];
        }
        
        [self.layer addSublayer:titleBar];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(back.frame, touchPoint)) {
        weekOffset -= 1;
        [self updateDates];
    } else if (CGRectContainsPoint(forward.frame, touchPoint)) {
        weekOffset += 1;
        [self updateDates];
    }
    
    for (CALayer *layer in dayLayers) {
        if (CGRectContainsPoint(layer.frame, touchPoint)) {
            if ([self.delegate respondsToSelector:@selector(weekViewSelectedDate:)]) {
                [self.delegate performSelector:@selector(weekViewSelectedDate:) withObject:[layer valueForKey:@"date"]];
            }
        }
    }
}

- (void)updateDates {
    
    NSDate *currentDay = [self beginningOfWeek];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM YYYY"];
    title.string = [formatter stringFromDate:currentDay];
    [formatter release];
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    int i = 0;
    for (CALayer *layer in dayLayers) {
        CATextLayer *text = [[layer sublayers] objectAtIndex:0];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:currentDay];
        
        text.string = [NSString stringWithFormat:@"%ld", (long)[components day]];
        
        [layer setValue:currentDay forKey:@"date"];
        
        if (i == 0 || i == 6) {
            layer.backgroundColor = [[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0] CGColor];
            text.foregroundColor = [[UIColor grayColor] CGColor];
        } else if ([components isEqual:today]) {
            layer.backgroundColor = [[UIColor colorWithRed:227/255.0 green:234/255.0 blue:246/255.0 alpha:1.0] CGColor];
            text.foregroundColor = [[UIColor colorWithRed:41/255.0 green:121/255.0 blue:242/255.0 alpha:1.0] CGColor];
        } else {
            layer.backgroundColor = [[UIColor whiteColor] CGColor];
            text.foregroundColor = [[UIColor grayColor] CGColor];
        }
        
        i++;
        currentDay = [currentDay dateByAddingTimeInterval:86400];
    }
}

- (NSDate *)beginningOfWeek {
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:today];
    /*
     Create a date components to represent the number of days to subtract
     from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so
     subtract 1 from the number
     of days to subtract from the date in question.  (If today's Sunday,
     subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    /* Substract [gregorian firstWeekday] to handle first day of the week being something else than Sunday */
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday])];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    [componentsToSubtract release];
    
    /*
     Optional step:
     beginningOfWeek now has the same hour, minute, and second as the
     original date (today).
     To normalize to midnight, extract the year, month, and day components
     and create a new date from those components.
     */
    NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate: beginningOfWeek];
    beginningOfWeek = [gregorian dateFromComponents: components];
    beginningOfWeek = [beginningOfWeek dateByAddingTimeInterval:weekOffset * 604800];
    
    return beginningOfWeek;
}

- (void)dealloc
{
    [super dealloc];
}

@end
