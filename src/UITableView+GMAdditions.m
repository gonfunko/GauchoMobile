//
//  UITableView+GMAdditions.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 9/24/12.
//
//

#import "UITableView+GMAdditions.h"

@implementation UITableView (UITableView_GMAdditions)

- (CGRect)boundsForPlaceholderLabel {
    NSInteger height = self.frame.size.height;
    NSInteger visibleRows = floor(height / self.rowHeight);
    NSInteger rowToDisplayOn = ceil(visibleRows / 2.0) - 1;
    
    return CGRectMake(0, rowToDisplayOn * self.rowHeight, self.bounds.size.width, self.rowHeight);
}

@end
