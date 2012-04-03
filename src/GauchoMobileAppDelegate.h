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
#import "GMSplitViewController.h"

@interface GauchoMobileAppDelegate : NSObject <UIApplicationDelegate, UISplitViewControllerDelegate, GMSourceFetcherDelegate> {
@private
    GMSourceFetcher *sourceFetcher;
    MainTabBarViewController *detail;
    CourseViewController *courseController;
    UIPopoverController *masterPopoverController;
    UIAlertView *waitMessage;
    UIActivityIndicatorView *indicator;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (retain) UIPopoverController *masterPopoverController;
@property (retain) MainTabBarViewController *detail;
@property (retain) CourseViewController *courseController;

@end
