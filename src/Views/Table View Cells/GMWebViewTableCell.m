//
//  GMWebViewTableCell.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 1/15/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMWebViewTableCell.h"

@implementation GMWebViewTableCell

@synthesize webview;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
        self.webview = [[[UIWebView alloc] initWithFrame:[self frame]] autorelease];
        self.webview.scrollView.scrollEnabled = NO;
        self.webview.backgroundColor = [UIColor clearColor];
        self.webview.opaque = NO;
        [self addSubview:self.webview];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.webview.frame = CGRectMake(frame.origin.x + 10, 0, frame.size.width - 20, frame.size.height - 10);
    } else {
        self.webview.frame = CGRectMake(frame.origin.x + 33, 0, frame.size.width - 66, frame.size.height - 10);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    self.webview = nil;
    [super dealloc];
}

@end
