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

@interface ParticipantsViewController : UIViewController<GMSourceFetcherDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate> {
@private
    NSMutableDictionary *sections;
    NSMutableDictionary *pictures;
    NSMutableArray *photoRequests;
	GMSourceFetcher *fetcher;
    GMLoadingView *loadingView;
    EGORefreshTableHeaderView *reloadView;
    
    BOOL loading;
    
    IBOutlet UITableView *tableView;
}

@property (retain) UITableView *tableView;

//Loads participants from the network, optionally with or without the yellow loading view
- (void)loadParticipantsWithLoadingView:(BOOL)flag;

//Returns an array of GMParticipant objects whose last names start with the given letter
- (NSArray *)participantsWithLastNameStartingWithLetter:(NSString *)letter;

//Loads and caches profile pictures for all participants
- (void)loadPicturesForParticipants;

//Displays the address book card for the given participant, if any
- (void)displayAddressBookEntryForParticipant:(GMParticipant *)participant;

@end
