//
//  GMParticipantCollectionViewCell.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 12/20/12.
//
//

#import "GMParticipantCollectionViewCell.h"

@interface GMParticipantCollectionViewCell ()

@property (readwrite, retain) UIImageView *imageView;
@property (readwrite, retain) UILabel *label;

@end

@implementation GMParticipantCollectionViewCell

@synthesize imageView;
@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, frame.size.width - 20)];
        image.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        image.layer.shadowOffset = CGSizeMake(0, 0);
        image.layer.shadowOpacity = 0.5;
        image.layer.shadowRadius = 4;
        image.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        image.layer.shouldRasterize = YES;
        self.imageView = image;
        [image release];
        
        UILabel *imageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
        imageLabel.font = [UIFont boldSystemFontOfSize:12.0];
        imageLabel.textAlignment = UITextAlignmentCenter;
        imageLabel.textColor = [UIColor colorWithRed:84/255.0 green:95/255.0 blue:105/255.0 alpha:1.0];
        imageLabel.backgroundColor = [UIColor clearColor];
        self.label = imageLabel;
        [imageLabel release];

        [self addSubview:self.label];
        [self addSubview:self.imageView];
                              
    }
    return self;
}

@end
