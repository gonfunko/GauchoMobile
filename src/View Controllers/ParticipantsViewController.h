//
//  ParticipantsViewController.h
//  Handles presentation and interaction with the list of participants
//  Created by Group J5 for CS48
//  

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMParticipantsParser.h"
#import "GMPersonViewController.h"
#import "UITableView+GMAdditions.h"

@interface ParticipantsViewController : UITableViewController <GMSourceFetcherDelegate, UIScrollViewDelegate> {
@protected
    NSArray *sections;
    NSMutableDictionary *pictures;
	GMSourceFetcher *fetcher;
    ABAddressBookRef addressBook;
}

@property (copy) NSArray *sections;

//Loads participants from the network
- (void)loadParticipants;

//Loads and caches profile pictures for all participants
- (void)loadPicturesForParticipants;

//Displays the address book card for the given participant, if any
- (void)displayAddressBookEntryForParticipant:(GMParticipant *)participant;

- (void)gotImageData:(NSDictionary *)imgData;

@end
