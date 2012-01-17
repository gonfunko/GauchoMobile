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
        UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, -3, self.frame.size.width + 6, self.frame.size.height + 6)];
        bg.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:bg];
        
        firstButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        firstButton.frame = CGRectMake(10, self.frame.origin.y, (self.frame.size.width - 40) / 2.0, self.frame.size.height);
        [firstButton setTitle:@"Hello" forState:UIControlStateNormal];
        [self addSubview:firstButton];
        
        secondButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        secondButton.frame = CGRectMake(30 + ((self.frame.size.width - 40) / 2.0), self.frame.origin.y, (self.frame.size.width - 40) / 2.0, self.frame.size.height);
        [secondButton setTitle:@"World" forState:UIControlStateNormal];
        [self addSubview:secondButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
