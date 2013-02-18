//
//  GMOTableView.h
//  GauchoMobile
//
//  GMOTableView is a UITableView subclass that adds a placeholder label (the "No _____" text) when
//  a table view does not contain any items and dynamically positions it based on the table view's
//  dimensions and row height
//

#import <UIKit/UIKit.h>

@interface GMOTableView : UITableView

@property (readonly) UILabel *placeholderLabel;

@end
