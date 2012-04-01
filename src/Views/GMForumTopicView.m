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
        self.layer.backgroundColor = [[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0] CGColor];
        
        photoRequests = [[NSMutableArray alloc] init];
        photoLayers = [[NSMutableDictionary alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dictPath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%ipics", (int)[[GMDataSource sharedDataSource] currentCourse].courseID]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:dictPath]) {
            pictures = [[NSKeyedUnarchiver unarchiveObjectWithFile:dictPath] retain];
        }
        else
            pictures = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
       self.layer.backgroundColor = [[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0] CGColor];
        
        photoRequests = [[NSMutableArray alloc] init];
        photoLayers = [[NSMutableDictionary alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dictPath = [[paths objectAtIndex:0] stringByAppendingString:[NSString stringWithFormat:@"/%ipics", (int)[[GMDataSource sharedDataSource] currentCourse].courseID]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:dictPath]) {
            pictures = [[NSKeyedUnarchiver unarchiveObjectWithFile:dictPath] retain];
        }
        else
            pictures = [[NSMutableDictionary alloc] init];
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
        background.opaque = YES;
        background.frame = CGRectMake(10, verticalOffset, self.frame.size.width - 20, contentHeight.height + 65);
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, background.frame.size.width, 55)
                                                       byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                             cornerRadii:CGSizeMake(6.0, 6.0)];
        CAShapeLayer *headerBackground = [[CAShapeLayer alloc] init];
        headerBackground.frame = CGRectMake(0, 0, background.frame.size.width, 55);
        headerBackground.fillColor = [[UIColor whiteColor] CGColor];
        headerBackground.path = maskPath.CGPath;
        headerBackground.opaque = YES;
        [background addSublayer:headerBackground];
        [headerBackground release];
        
        CALayer *dividingLine = [[CALayer alloc] init];
        dividingLine.frame = CGRectMake(0, 55, background.frame.size.width, 1);
        dividingLine.backgroundColor = [[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0] CGColor];
        dividingLine.opaque = YES;
        [background addSublayer:dividingLine];
        CALayer *dividingLineShadow = [[CALayer alloc] init];
        dividingLineShadow.backgroundColor = [[UIColor whiteColor] CGColor];
        dividingLineShadow.frame = CGRectMake(0, 56, background.frame.size.width, 1);
        dividingLineShadow.opaque = YES;
        [background addSublayer:dividingLineShadow];
        [dividingLine release];
        [dividingLineShadow release];
        
        [self.layer addSublayer:background];
        [background release];
        
        CALayer *userPhoto = [[CALayer alloc] init];
        userPhoto.contents = (id)[[UIImage imageNamed:@"defaulticon.png"] CGImage];
        userPhoto.cornerRadius = 2.0;
        userPhoto.frame = CGRectMake(10, 7, 40, 40);
        userPhoto.opaque = YES;
        if ([photoLayers objectForKey:[post.author.imageURL absoluteString]] == nil) {
            NSMutableSet *layers = [NSMutableSet set];
            [photoLayers setObject:layers forKey:[post.author.imageURL absoluteString]];
        }
        
        [[photoLayers objectForKey:[post.author.imageURL absoluteString]] addObject:userPhoto];
        [background addSublayer:userPhoto];
        [userPhoto release];
        
        CATextLayer *author = [[CATextLayer alloc] init];
        author.string = post.author.name;
        author.fontSize = 14.0;
        author.font = @"Helvetica-Bold";
        author.foregroundColor = [[UIColor darkGrayColor] CGColor];
        author.frame = CGRectMake(60, 10, self.frame.size.width - 110, 20);
        author.contentsScale = [[UIScreen mainScreen] scale];
        [background addSublayer:author];
        [author release];
        
        CATextLayer *date = [[CATextLayer alloc] init];
        date.string = [NSString stringWithFormat:@"Posted %@", [formatter stringFromDate:post.postDate]];
        date.fontSize = 12.0;
        date.font = @"Helvetica";
        date.foregroundColor = [[UIColor lightGrayColor] CGColor];
        date.frame = CGRectMake(60, 28, self.frame.size.width - 110, 20);
        date.contentsScale = [[UIScreen mainScreen] scale];
        [background addSublayer:date];
        [date release];
        
        CATextLayer *content = [[CATextLayer alloc] init];
        content.wrapped = YES;
        content.string = post.message;
        content.fontSize = 14.0;
        content.font = @"Helvetica";
        content.foregroundColor = [[UIColor darkGrayColor] CGColor];
        content.frame = CGRectMake(10, 65, self.frame.size.width - 40, contentHeight.height);
        content.contentsScale = [[UIScreen mainScreen] scale];
        [background addSublayer:content];
        [content release];
        
        verticalOffset += background.frame.size.height + 15;
    }
    
    [formatter release];
    
    self.frame = CGRectMake(0, 0, 320, verticalOffset);
    
    [self loadPicturesForParticipants:forumPosts];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [photoRequests removeObject:request];
    NSData *imageData = [request responseData];
    UIImage *pic = [UIImage imageWithData:imageData];
    NSMutableSet *layers = [photoLayers objectForKey:[[request originalURL] absoluteString]];
    for (CALayer *layer in layers) {
        layer.contents = (id)[pic CGImage];
    }
    
    [pictures setObject:pic forKey:[[request originalURL] absoluteString]];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [photoRequests removeObject:request];
    NSError *error = [request error];
    NSLog(@"Downloading profile picture failed with error %@", [error description]);
}

- (void)loadPicturesForParticipants:(NSArray *)forumPosts {
    NSMutableArray *allParticipants = [[NSMutableArray alloc] init];
    
    for (GMForumPost *post in forumPosts) {
        [allParticipants addObject:post.author];
    }
    
    for (GMParticipant *participant in allParticipants) {
        NSString *url = [participant.imageURL absoluteString];
        if (![url isEqualToString:@"https://gauchospace.ucsb.edu/courses/theme/gaucho/pix/u/f1.png"]) {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
            [request setDelegate:self];
            [request startAsynchronous];
            [photoRequests addObject:request];
        }
    }
    
    [allParticipants release];
}

- (void)dealloc {
    NSArray *requests = [NSArray arrayWithArray:photoRequests];
    for (ASIHTTPRequest *request in requests) {
        [request clearDelegatesAndCancel];
    }
    
    [photoRequests release];
    [pictures release];
    [photoLayers release];
    [super dealloc];
}

@end
