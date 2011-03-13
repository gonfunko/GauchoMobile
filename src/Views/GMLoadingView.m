//
//  GMLoadingView.m
//  Yellow banded view that indicates information is loading
//  Created by Group J5 for CS48
//

#import "GMLoadingView.h"


@implementation GMLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0, 2.0);
        self.layer.shadowOpacity = 0.75;
        
        CALayer *maskLayer = [CALayer layer];    
        maskLayer.frame = CGRectMake(0, -10, [self frame].size.width, [self frame].size.height + 10);
        maskLayer.cornerRadius = 10;
        maskLayer.backgroundColor = [[UIColor blackColor] CGColor];
        maskLayer.masksToBounds = YES;
        
        CALayer *base = [CALayer layer];
        base.frame = CGRectMake(0, 0, [self frame].size.width, [self frame].size.height);
        base.mask = maskLayer;
        [[self layer] addSublayer:base];
    
        CALayer *bands = [CALayer layer];
        bands.contents = (id)[[UIImage imageNamed:@"bands.png"] CGImage];
        bands.frame = CGRectMake(-320, 0, [[UIImage imageNamed:@"bands.png"] size].width * [self frame].size.height / 100.0, [self frame].size.height);
        bands.opacity = 0.5;
        [base addSublayer:bands];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [bands valueForKey:@"position"];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake([bands position].x + 305, [bands position].y)];
        animation.duration = 10.0;
        animation.repeatCount = 1000;
        [bands addAnimation:animation forKey:@"position"];
        
        UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(0, 4.4, [self frame].size.width, 20)];
        text.text = @"Loading...";
        text.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        text.textColor = [UIColor darkGrayColor];
        text.textAlignment = UITextAlignmentCenter;
        [self addSubview:text];
        [text release];
        
        UITextField *text2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, [self frame].size.width, 20)];
        text2.text = @"Loading...";
        text2.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
        text2.textColor = [UIColor whiteColor];
        text2.textAlignment = UITextAlignmentCenter;
        [self addSubview:text2];
        [text2 release];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddArcToPoint(context, 0, [self frame].size.height, 10, [self frame].size.height, 10.0f);
    CGContextAddArcToPoint(context, [self frame].size.width, [self frame].size.height, [self frame].size.width, [self frame].size.height - 10, 10.0f);
    CGContextAddLineToPoint(context, [self frame].size.width, 0);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat locations[] = {0.0f, 1.0f};
    
    CGFloat startComponents[] = {242/255.0f, 206/255.0f, 68/255.0f, 1.0f};
    CGColorRef start = CGColorCreate(colorSpace, startComponents);
    CGFloat endComponents[] = {239/255.0f, 172/255.0f, 30/255.0f, 1.0f};
    CGColorRef end = CGColorCreate(colorSpace, endComponents);
    
    CFMutableArrayRef colors = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
    CFArrayAppendValue(colors, (const void *)start);
    CFArrayAppendValue(colors, (const void *)end);
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, [self frame].size.height), kCGGradientDrawsBeforeStartLocation);
    
    CFRelease(colorSpace);
    CFRelease(start);
    CFRelease(end);
    CFRelease(colors);
    CFRelease(gradient);
}

- (void)dealloc
{
    [super dealloc];
}

@end
