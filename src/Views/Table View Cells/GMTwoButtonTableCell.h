//
//  GMTwoButtonTableCell.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 1/16/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMTwoButtonTableCell : UITableViewCell {
    UIButton *firstButton;
    UIButton *secondButton;
}

@property (readonly) UIButton *firstButton;
@property (readonly) UIButton *secondButton;

@end
