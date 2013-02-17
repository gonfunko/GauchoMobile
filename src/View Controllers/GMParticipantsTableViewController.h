//
//  GMOParticipantsViewController.h
//  GauchoMobile
//
//  GMParticipantsTableViewController is responsible for providing data, configuring cells and
//  managing selections for the list of participants in a course
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "GMDataSource.h"
#import "UITableView+GMAdditions.h"
#import "GMOParticipantsViewController.h"

@interface GMParticipantsTableViewController : UITableViewController <GMParticipantsChildViewController> 

@end
