//
//  GMOTableView.m
//  GauchoMobile
//
//  GMOTableView is a UITableView subclass that adds a placeholder label (the "No _____" text) when
//  a table view does not contain any items and dynamically positions it based on the table view's
//  dimensions and row height
//

#import "GMOTableView.h"

@interface GMOTableView ()

@property (retain, readwrite) UILabel *placeholderLabel;

@end

@implementation GMOTableView

@synthesize placeholderLabel;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // Configure the label and hide it by default
        self.placeholderLabel = [[UILabel alloc] init];
        self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.placeholderLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        self.placeholderLabel.textColor = [UIColor grayColor];
        self.placeholderLabel.textAlignment = UITextAlignmentCenter;
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.hidden = YES;
        
        // Add the label to the table view
        [self addSubview:self.placeholderLabel];
    }
    
    return self;
}

- (id)init {
    if (self = [super init]) {
        // Configure the label and hide it by default
        self.placeholderLabel = [[UILabel alloc] init];
        self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.placeholderLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        self.placeholderLabel.textColor = [UIColor grayColor];
        self.placeholderLabel.textAlignment = UITextAlignmentCenter;
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.hidden = YES;
        
        // Add the label to the table view
        [self addSubview:self.placeholderLabel];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // Whenever our frame changes, recalculate where to place the label
    NSInteger height = self.frame.size.height;
    // Determine how many rows are on screen
    NSInteger visibleRows = floor(height / self.rowHeight);
    /* Determine which one corresponds to the middle,
       choosing the one above in the case of an even number of rows */
    NSInteger rowToDisplayOn = ceil(visibleRows / 2.0) - 1;
    
    self.placeholderLabel.frame = CGRectMake(0, rowToDisplayOn * self.rowHeight, self.bounds.size.width, self.rowHeight);
}

- (void)reloadData {
    [super reloadData];
    
    // Assuming there is at least one section with one row, hide the placeholder label
    if (self.numberOfSections != 0 && [self numberOfRowsInSection:0] != 0) {
        self.placeholderLabel.hidden = YES;
    } else {
        // Otherwise, make it visible
        self.placeholderLabel.hidden = NO;
    }
}

@end
