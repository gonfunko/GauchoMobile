//
//  GauchoMobileAppDelegate.m
//  Manages launch and termination of GauchoMobile
//  Created by Group J5 for CS48
//


#import "GauchoMobileAppDelegate.h"

@implementation GauchoMobileAppDelegate


@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navController = [[UINavigationController alloc] init];
    self.window.rootViewController = navController;
    
    //Create the course view controller and set it as the root view controller
    CourseViewController *courseController = [[CourseViewController alloc] initWithNibName:@"CourseViewController" bundle:[NSBundle mainBundle]];
    [navController pushViewController:courseController animated:NO];
    [navController release];
    [courseController release];
    
    [self.window makeKeyAndVisible];
    
    //Create and display the login view controller
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    [self.window.rootViewController presentModalViewController:login animated:NO];
    [login release];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    //Cache data when we go into the background
    [[GMDataSource sharedDataSource] archiveData];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[GMDataSource sharedDataSource] archiveData];
}

- (void)dealloc {

    [window release];
    [super dealloc];
}

@end
