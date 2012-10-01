//
//  GMTwoButtonTableCell.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 1/16/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMTwoButtonTableCell.h"

@implementation GMTwoButtonTableCell

@synthesize firstButton;
@synthesize secondButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *backView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        backView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backView;
        
        self.firstButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.firstButton.frame = CGRectMake(10, self.frame.origin.y, (self.frame.size.width - 40) / 2.0, self.frame.size.height);
        [self.firstButton setTitle:@"Hello" forState:UIControlStateNormal];
        [self addSubview:firstButton];
        
        self.secondButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.secondButton.frame = CGRectMake(30 + ((self.frame.size.width - 40) / 2.0), self.frame.origin.y, (self.frame.size.width - 40) / 2.0, self.frame.size.height);
        [self.secondButton setTitle:@"World" forState:UIControlStateNormal];
        [self addSubview:secondButton];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.firstButton.frame = CGRectMake(10, 0, (self.frame.size.width - 40) / 2.0, self.frame.size.height);
        self.secondButton.frame = CGRectMake(30 + ((self.frame.size.width - 40) / 2.0), 0, (self.frame.size.width - 40) / 2.0, self.frame.size.height);
    } else {
        self.firstButton.frame = CGRectMake(30, 0, (self.frame.size.width - 80) / 2.0, self.frame.size.height);
        self.secondButton.frame = CGRectMake(50 + ((self.frame.size.width - 80) / 2.0), 0, (self.frame.size.width - 80) / 2.0, self.frame.size.height);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
