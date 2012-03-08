//
//  GMForumTopicView.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/15/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMForumTopicView.h"

@implementation GMForumTopicView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.backgroundColor = [[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0] CGColor];
    }
    return self;
}

- (void)setPosts:(NSArray *)forumPosts {
    int verticalOffset = 15.0;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/d/y h:mm a"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    for (GMForumPost *post in forumPosts) {
        
        CGSize contentHeight = [post.message sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(self.frame.size.width - 40, 500)];
        
        CALayer *background = [[CALayer alloc] init];
        background.backgroundColor = [[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0] CGColor];
        background.cornerRadius = 6.0;
        background.shadowOffset = CGSizeMake(0, 0);
        background.shadowColor = [[UIColor darkGrayColor] CGColor];
        background.shadowRadius = 2.0;
        background.shadowOpacity = 0.8;
        background.borderColor = [[UIColor grayColor] CGColor];
        background.frame = CGRectMake(10, verticalOffset, self.frame.size.width - 20, contentHeight.height + 65);
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, background.frame.size.width, 55)
                                                       byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                             cornerRadii:CGSizeMake(6.0, 6.0)];
        CAShapeLayer *headerBackground = [[CAShapeLayer alloc] init];
        headerBackground.frame = CGRectMake(0, 0, background.frame.size.width, 55);
        headerBackground.fillColor = [[UIColor whiteColor] CGColor];
        headerBackground.path = maskPath.CGPath;
        [background addSublayer:headerBackground];
        [headerBackground release];
        
        CALayer *dividingLine = [[CALayer alloc] init];
        dividingLine.frame = CGRectMake(0, 55, background.frame.size.width, 1);
        dividingLine.backgroundColor = [[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0] CGColor];
        [background addSublayer:dividingLine];
        CALayer *dividingLineShadow = [[CALayer alloc] init];
        dividingLineShadow.backgroundColor = [[UIColor whiteColor] CGColor];
        dividingLineShadow.frame = CGRectMake(0, 56, background.frame.size.width, 1);
        [background addSublayer:dividingLineShadow];
        [dividingLine release];
        [dividingLineShadow release];
        
        [self.layer addSublayer:background];
        [background release];
        
        CALayer *userPhoto = [[CALayer alloc] init];
        userPhoto.contents = (id)[[UIImage imageNamed:@"defaulticon.png"] CGImage];
        userPhoto.cornerRadius = 2.0;
        userPhoto.frame = CGRectMake(10, 7, 40, 40);
        [background addSublayer:userPhoto];
        [userPhoto release];
        
        CATextLayer *author = [[CATextLayer alloc] init];
        author.string = post.author.name;
        author.fontSize = 14.0;
        author.font = @"Helvetica-Bold";
        author.foregroundColor = [[UIColor darkGrayColor] CGColor];
        author.frame = CGRectMake(60, 10, 210, 20);
        author.contentsScale = [[UIScreen mainScreen] scale];
        [background addSublayer:author];
        [author release];
        
        CATextLayer *date = [[CATextLayer alloc] init];
        date.string = [NSString stringWithFormat:@"Posted %@", [formatter stringFromDate:post.postDate]];
        date.fontSize = 12.0;
        date.font = @"Helvetica";
        date.foregroundColor = [[UIColor lightGrayColor] CGColor];
        date.frame = CGRectMake(60, 28, 210, 20);
        date.contentsScale = [[UIScreen mainScreen] scale];
        [background addSublayer:date];
        [date release];
        
        CATextLayer *content = [[CATextLayer alloc] init];
        content.wrapped = YES;
        content.string = post.message;
        content.fontSize = 14.0;
        content.font = @"Helvetica";
        content.foregroundColor = [[UIColor darkGrayColor] CGColor];
        content.frame = CGRectMake(10, 65, 280, contentHeight.height);
        content.contentsScale = [[UIScreen mainScreen] scale];
        [background addSublayer:content];
        [content release];
        
        verticalOffset += background.frame.size.height + 15;
    }
    
    self.frame = CGRectMake(0, 0, 320, verticalOffset);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
