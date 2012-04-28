//
//  GMTextViewTableCell.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GMTextViewTableCell.h"


@implementation GMTextViewTableCell

@synthesize textView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [[[UITextView alloc] initWithFrame:[self frame]] autorelease];
        self.textView.scrollEnabled = NO;
        self.textView.editable = NO;
        self.textView.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        [self addSubview:textView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.textView.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height);
    } else {
        self.textView.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc
{
    [super dealloc];
}

@end
