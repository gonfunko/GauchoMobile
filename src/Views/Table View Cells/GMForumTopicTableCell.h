//
//  GMForumTopicTableCell.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/11/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMForumTopicTableCell : UITableViewCell {
    IBOutlet UILabel *title;
    IBOutlet UILabel *author;
    IBOutlet UILabel *date;
    IBOutlet UIButton *replies;
}

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *author;
@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UIButton *replies;

@end
