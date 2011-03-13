//
//  GMTextViewTableCell.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GMTextViewTableCell : UITableViewCell {
@private
    UITextView *textView;
}

@property (retain) UITextView *textView;

@end
