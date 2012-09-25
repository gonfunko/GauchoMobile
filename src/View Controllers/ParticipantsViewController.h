//
//  ParticipantsViewController.h
//  Handles presentation and interaction with the list of participants
//  Created by Group J5 for CS48
//  

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ASIHTTPRequest.h"
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMParticipantsParser.h"
#import "MBProgressHUD.h"
#import "GMPersonViewController.h"
#import "UITableView+GMAdditions.h"

@interface ParticipantsViewController : UIViewController<GMSourceFetcherDelegate, UIScrollViewDelegate> {
@protected
    NSArray *sections;
    NSMutableDictionary *pictures;
    NSMutableArray *photoRequests;
	GMSourceFetcher *fetcher;
    MBProgressHUD *HUD;
    ABAddressBookRef addressBook;
    
    BOOL loading;
    
    IBOutlet UITableView *tableView;
}

@property (retain) UITableView *tableView;
@property (copy) NSArray *sections;

//Loads participants from the network, optionally with or without the yellow loading view
- (void)loadParticipantsWithLoadingView:(BOOL)flag;

//Loads and caches profile pictures for all participants
- (void)loadPicturesForParticipants;

//Displays the address book card for the given participant, if any
- (void)displayAddressBookEntryForParticipant:(GMParticipant *)participant;

- (void)requestFinished:(ASIHTTPRequest *)request;

@end
