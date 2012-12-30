//
//  GMForumPostTableCell.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 12/29/12.
//
//

#import <UIKit/UIKit.h>

@interface GMForumPostTableCell : UITableViewCell {
    IBOutlet UIImageView *userPhoto;
    IBOutlet UILabel *name;
    IBOutlet UILabel *date;
    IBOutlet UITextView *post;
}

@property (nonatomic, retain) IBOutlet UIImageView *userPhoto;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UITextView *post;

@end
