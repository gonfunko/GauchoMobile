//
//  GMForumTopicTableCell.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/11/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMForumTopicTableCell.h"

@implementation GMForumTopicTableCell

@synthesize title;
@synthesize author;
@synthesize date;
@synthesize replies;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    self.title = nil;
    self.author = nil;
    self.date = nil;
    [super dealloc];
}

@end
