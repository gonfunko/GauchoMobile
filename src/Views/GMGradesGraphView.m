//
//  GMGradesGraphView.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GMGradesGraphView.h"


@implementation GMGradesGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        barLayers = nil;
        
        self.layer.backgroundColor = [[UIColor blackColor] CGColor];
        self.layer.masksToBounds = YES;
        
        [self loadBars];
        
        average = [CATextLayer layer];
        average.foregroundColor = [[UIColor whiteColor] CGColor];
        average.alignmentMode = kCAAlignmentCenter;
        average.string = [NSString stringWithFormat:@"%i%%", courseAverage];
        average.font = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica-Bold" size:48.0].fontName);
        average.fontSize = 48.0;
        average.frame = CGRectMake(self.frame.size.width - 150, 20, 150, [average preferredFrameSize].height);
        average.alignmentMode = kCAAlignmentCenter;
        average.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:average];
        
        currentGrade = [CATextLayer layer];
        currentGrade.string = @"Average";
        currentGrade.foregroundColor = [[UIColor grayColor] CGColor];
        currentGrade.fontSize = 14.0;
        currentGrade.font = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica" size:14.0].fontName);
        currentGrade.contentsScale = [[UIScreen mainScreen] scale];
        currentGrade.frame = CGRectMake(self.frame.size.width - 150 + ((150 - [average preferredFrameSize].width) / 2), 60, 150, 20);
        currentGrade.alignmentMode = kCAAlignmentLeft;
        [self.layer addSublayer:currentGrade];
    }
    return self;
}

- (void)loadBars {
    
    //Remove any preexisting bars
    if (barLayers != nil) {
        for (CAGradientLayer *layer in barLayers) {
            [layer removeFromSuperlayer];
        }
        [barLayers removeAllObjects];
    } else {
        barLayers = [[NSMutableArray alloc] init];
    }
    
    //Get the current grades from the data source
    NSArray *grades = [[[GMDataSource sharedDataSource] currentCourse] grades];
    int width = (self.frame.size.width - 150) / [grades count];
    int bars = 0;
    int earned = 0;
    int total = 0;
    
    for (GMGrade *grade in grades) {
        //Sum earned and total points to calculate average later
        earned += grade.score;
        total += grade.max;
        
        CAGradientLayer *layer = [CAGradientLayer layer];
        
        //Each bar is a yellow gradient; set up the layer here
        CGColorRef first = [[UIColor colorWithRed:242/255.0 green:206/255.0 blue:68/255.0 alpha:1.0] CGColor];
        CGColorRef second = [[UIColor colorWithRed:239/255.0 green:172/255.0 blue:30/255.0 alpha:1.0] CGColor];
        layer.colors = [NSArray arrayWithObjects:(id)first, (id)second, nil];
        layer.borderColor = [[UIColor darkGrayColor] CGColor];
        layer.borderWidth = 0.5;
        [layer setValue:grade.description forKey:@"gradeDescription"];
        [layer setValue:[NSNumber numberWithInt:(int)((double)grade.score / (double)grade.max * 100)] forKey:@"gradePercentage"];
        [barLayers addObject:layer];
        
        int height = (self.frame.size.height - 20) * (double)grade.score / (double)grade.max;
        layer.frame = CGRectMake(bars * width + 10, self.frame.size.height - height, width, height);
        [self.layer addSublayer:layer];
        
        //If we've got a bit of room, badge each bar with its percentage.
        if (width > 40) {
            CATextLayer *percentage = [CATextLayer layer];
            percentage.string = [NSString stringWithFormat:@"%i%%", (int)((double)grade.score / (double)grade.max * 100)];
            percentage.font = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica-Bold" size:14.0].fontName);
            percentage.fontSize = 14.0;
            percentage.foregroundColor = [[UIColor whiteColor] CGColor];
            percentage.contentsScale = [[UIScreen mainScreen] scale];
            percentage.frame = CGRectMake((layer.frame.size.width - [percentage preferredFrameSize].width) / 2, (int)(layer.frame.size.height / 2 + 4), [percentage preferredFrameSize].width, 16);
            percentage.alignmentMode = kCAAlignmentCenter;
            percentage.shadowColor = [[UIColor blackColor] CGColor];
            percentage.shadowOffset = CGSizeMake(0, -1);
            percentage.shadowRadius = 0.0;
            percentage.shadowOpacity = 1.0;
            
            CALayer *background = [CALayer layer];
            background.backgroundColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6] CGColor];
            background.cornerRadius = 5.0;
            background.frame = CGRectMake((layer.frame.size.width - [percentage preferredFrameSize].width) / 2 - 2, layer.frame.size.height / 2.0, [percentage preferredFrameSize].width + 4, 20);
            
            [layer addSublayer:background];
            [layer addSublayer:percentage];
        }
        bars++;
    }
    
    courseAverage = (int)((double)earned / (double)total * 100);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    currentGrade.string = @"Average";
    average.string = [NSString stringWithFormat:@"%i%%", courseAverage];
    
    for (CAGradientLayer *layer in barLayers) {
        if (CGRectContainsPoint(layer.frame, touchPoint)) {
            CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeAnimation.duration = 0.5;
            fadeAnimation.repeatCount = 2000;
            fadeAnimation.autoreverses = YES;
            fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0];
            fadeAnimation.toValue = [NSNumber numberWithFloat:0.4];
            [layer addAnimation:fadeAnimation forKey:@"opacity"];
            
            currentGrade.string = [layer valueForKey:@"gradeDescription"];
            average.string = [NSString stringWithFormat:@"%i%%", [[layer valueForKey:@"gradePercentage"] intValue]];
        } else {
            [layer removeAllAnimations];
        }
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
