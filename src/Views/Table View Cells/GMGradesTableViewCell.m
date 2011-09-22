//
//  GMGradesTableViewCell.m
//  Custom cell that presents information about a GMGrade
//  Created by Group J5 for CS48
//


#import "GMGradesTableViewCell.h"


@implementation GMGradesTableViewCell

@synthesize description;
@synthesize outof;
@synthesize percentage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        percentage = [[UITextField alloc] initWithFrame:CGRectMake(10, [self frame].origin.y+5, [self frame].size.width-20, [self frame].size.height-10)];
        percentage.font = [UIFont fontWithName:@"Helvetica-Bold" size:30.0];
        percentage.text = @"100%";
        percentage.enabled = NO;
        [self addSubview:percentage];
        
        outof = [[UITextField alloc] initWithFrame:CGRectMake(100, [self frame].origin.y+27, [self frame].size.width-80, 14)];
        outof.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        outof.text = @"outof 10/100";
        outof.textColor = [UIColor grayColor];
        outof.enabled = NO;
        [self addSubview:outof];
        
        description = [[UITextField alloc] initWithFrame:CGRectMake(100, [self frame].origin.y+5, [self frame].size.width-125, 30)];
        description.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        description.text = @"some descriptiongg";
        description.enabled = NO;
        [self addSubview:description];

    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        percentage.textColor = [UIColor whiteColor];
        outof.textColor = [UIColor whiteColor];
        description.textColor = [UIColor whiteColor];
    }
    else {
        percentage.textColor = [UIColor blackColor];
        outof.textColor = [UIColor grayColor];
        description.textColor = [UIColor blackColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        percentage.textColor = [UIColor whiteColor];
        outof.textColor = [UIColor whiteColor];
        description.textColor = [UIColor whiteColor];
    }
    else {
        percentage.textColor = [UIColor blackColor];
        outof.textColor = [UIColor grayColor];
        description.textColor = [UIColor blackColor];
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
