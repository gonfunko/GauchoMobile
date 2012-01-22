//
//  GauchoMobileAppDelegate.h
//  Manages launch and termination of GauchoMobile
//  Created by Group J5 for CS48
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "CourseViewController.h"
#import "GMSourceFetcher.h"
#import "KeychainItemWrapper.h"

@interface GauchoMobileAppDelegate : NSObject <UIApplicationDelegate, GMSourceFetcherDelegate> {
@private
    GMSourceFetcher *sourceFetcher;
    UIAlertView *waitMessage;
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
