//
//  GMParticipantsViewController.h
//  GauchoMobile
//
//  GMParticipantsViewController is the base view controller for the People view. It handles loading data,
//  loading and caching images of people enrolled in the class, and handling address book lookups
//  and presentation. Depending on the current device, it adds GMPeopleTableViewController or
//  GMPeopleCollectionViewController as a child view controller, which is responsible for managing
//  the view the user ultimately sees.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMParticipantsParser.h"
#import "GMPersonViewController.h"

@protocol GMParticipantsChildViewController <NSObject>
@required

// Called when the parent view controller begins loading data, so the child can update its UI
- (void)loadingStarted;

// Called when data has changed and the child view controller should re-fetch it from the parent
- (void)reloadData;

// Called when the parent view controller has finished loading data, so the child can update its UI
- (void)loadingFinished;
@end

@interface GMParticipantsViewController : UIViewController <GMSourceFetcherDelegate>

@property (retain, readonly) NSMutableDictionary *pictures;
@property (retain, readonly) NSArray *sections;
@property (assign, readonly) ABAddressBookRef addressBook;

- (void)displayAddressBookEntryForParticipant:(GMParticipant *)participant;

@end
