//
//  GMOForumPostsViewController.h
//  GauchoMobile
//
//  GMOForumPostsViewController is responsible for fetching and providing the list of posts in a
//  specific forum topic to a table view for presentation
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMDataSource.h"
#import "GMSourceFetcher.h"
#import "GMForumsParser.h"
#import "GMForumPostTableCell.h"

@interface GMOForumPostsViewController : UITableViewController <GMSourceFetcherDelegate>

@property (retain) GMForumTopic *topic;

@end
