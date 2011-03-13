//
//  GMGradesTableViewCell.h
//  Custom cell that presents information about a GMGrade
//  Created by Group J5 for CS48
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GMGradesTableViewCell : UITableViewCell {
@private
    UITextField *percentage; 
    UITextField *description;
    UITextField *outof;
    
}

@property (retain, readonly) UITextField *percentage;
@property (retain, readonly) UITextField *description;
@property (retain, readonly) UITextField *outof;

@end
