//
//  GMSourceFetcher.h
//  Downloads HTML source code from GauchoSpace
//  Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>
#import "GMCourse.h"
#import "GMForum.h"
#import "GMForumTopic.h"

//Formal protocol; all delegates passed to methods in this class must conform to it
@protocol GMSourceFetcherDelegate <NSObject>
@required
//Called when GMSourceFetcher did not fetch HTML successfully, with the error as an argument
- (void)sourceFetchDidFailWithError:(NSError *)error;

//Called when GMSourceFetcher did fetch HTML successfully, with the HTML as an argument
- (void)sourceFetchSucceededWithPageSource:(NSString *)source;
@end

@interface GMSourceFetcher : NSObject

//Attempts to log into GauchoSpace and calls sourceFetchSucceededWithPageSource: on the delegate with the HTML of the home page or login page (if invalid credentials)
//If login was successful, assignments, grades and participants may be fetched after the delegate receives its callback
- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(NSObject <GMSourceFetcherDelegate> *)delegate;

//Terminates the current session and logs out of GauchoSpace.
- (void)logout;

//Assuming loginWithUsername:password:delegate: has been called and login succeeded, passes the HTML for the GauchoSpace course home page corresponding to course to
//the delegate's sourceFetchSucceededWithPageSource: method
- (void)dashboardForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate;

//Assuming loginWithUsername:password:delegate: has been called and login succeeded, passes the HTML for the GauchoSpace assignments page corresponding to course to
//the delegate's sourceFetchSucceededWithPageSource: method
- (void)assignmentsForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate;

//Assuming loginWithUsername:password:delegate: has been called and login succeeded, passes the HTML for the GauchoSpace grades page corresponding to course to
//the delegate's sourceFetchSucceededWithPageSource: method
- (void)gradesForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate;

//Assuming loginWithUsername:password:delegate: has been called and login succeeded, passes the HTML for the GauchoSpace participants page corresponding to course to
//the delegate's sourceFetchSucceededWithPageSource: method
- (void)participantsForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate;

- (void)forumsForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate;

- (void)topicsForForum:(GMForum *)forum withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate;

- (void)postsForTopic:(GMForumTopic *)topic withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate;

- (void)detailsForAssignment:(GMAssignment *)assignment withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate;

@end
