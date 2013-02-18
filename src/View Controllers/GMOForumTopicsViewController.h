//
//  GMOForumTopicsViewController.h
//  GauchoMobile
//
//  GMOForumTopicsViewController is responsible for fetching and providing the list of topics in a
//  specific forum to a table view for presentation
//

#import <UIKit/UIKit.h>
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMForumsParser.h"
#import "GMForumTopicTableCell.h"
#import "GMOForumPostsViewController.h"
#import "GMOTableView.h"


@interface GMOForumTopicsViewController : UITableViewController <GMSourceFetcherDelegate>

// The forum whose topics this view controller is responsible for presenting
@property (retain) GMForum *forum;

@end
