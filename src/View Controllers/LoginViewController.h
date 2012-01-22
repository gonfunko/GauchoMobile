//
//  LoginViewController.h
//  Handles presentation and interaction with the login view
//  Created by Group J5 for CS48
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMSourceFetcher.h"
#import "GMDataSource.h"
#import "GMCourseParser.h"
#import "GMLoadingView.h"
#import "GMDashboardParser.h"
#import "KeychainItemWrapper.h"

@interface LoginViewController : UIViewController <GMSourceFetcherDelegate>{
@private
    CALayer *floatingBackground;
    int image;
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UIButton *loginButton;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIView *loginView;
    GMLoadingView *loadingView;
    KeychainItemWrapper *keychain;
}

//Called when login button is pressed; attempts to log into GauchoSpace using the entered name and password
- (IBAction)logIn:(id)sender;

@end
