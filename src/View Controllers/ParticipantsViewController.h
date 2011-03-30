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
#import "GMLoadingView.h"
#import "EGORefreshTableHeaderView.h"
#import "TKCoverflowView.h"
#import "TKCoverflowCoverView.h"

@interface ParticipantsViewController : UIViewController<GMSourceFetcherDelegate, EGORefreshTableHeaderDelegate, TKCoverflowViewDelegate, TKCoverflowViewDataSource, UIScrollViewDelegate> {
@private
    NSMutableDictionary *sections;
    NSMutableDictionary *pictures;
    NSMutableArray *photoRequests;
    UILabel *coverflowLabel;
	GMSourceFetcher *fetcher;
    GMLoadingView *loadingView;
    EGORefreshTableHeaderView *reloadView;
    TKCoverflowView *coverflow;
    
    BOOL loading;
    
    IBOutlet UITableView *tableView;
}

@property (retain) UITableView *tableView;

//Handles device rotation by switching between the landscape and portrait views
- (void)adjustForRotation;

//Loads participants from the network, optionally with or without the yellow loading view
- (void)loadParticipantsWithLoadingView:(BOOL)flag;

//Returns an array of GMParticipant objects whose last names start with the given letter
- (NSArray *)participantsWithLastNameStartingWithLetter:(NSString *)letter;

//Loads and caches profile pictures for all participants
- (void)loadPicturesForParticipants;

//Displays the address book card for the given participant, if any
- (void)displayAddressBookEntryForParticipant:(GMParticipant *)participant;

@end
