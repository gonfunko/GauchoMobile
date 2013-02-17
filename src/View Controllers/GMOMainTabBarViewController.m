//
//  GMOMainTabBarViewController.m
//  GauchoMobile
//
//  GMOMainTabBarController is responsible for managing the tab bar view that is presented when selecting a class.
//  In this case, this just means creating the view controllers, setting the icons/labels and making it look pretty.
//

#import "GMOMainTabBarViewController.h"

@implementation GMOMainTabBarViewController

- (id)init {
    if (self = [super init]) {
        // Create and configure the Dashboard VC and tab bar item
        DashboardViewController *dashboardController = [[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:[NSBundle mainBundle]];
        dashboardController.title = @"Dashboard";
        UIImage *selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"dashboard"]
                                       andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
        UIImage *tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"dashboard"]
                                     andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
        [dashboardController.tabBarItem setFinishedSelectedImage:selectedIcon
                                     withFinishedUnselectedImage:tabBarIcon];
        
        /* Create and configure the Assignments VC and tab bar item; this is different depending on whether
           we're running on an iPad or other iOS device, so allocate the correct view controller dependent on that */
        UIViewController *assignmentsController;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            assignmentsController = [[AssignmentsViewController alloc] initWithNibName:@"AssignmentsViewController" bundle:[NSBundle mainBundle]];
        } else {
            assignmentsController = [[GMiPadAssignmentsViewController alloc] initWithNibName:@"GMiPadAssignmentsViewController" bundle:[NSBundle mainBundle]];
        }
        assignmentsController.title = @"Assignments";
        selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"assignments"]
                              andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
        tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"assignments"]
                            andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
        [assignmentsController.tabBarItem setFinishedSelectedImage:selectedIcon
                                       withFinishedUnselectedImage:tabBarIcon];

        // Create and configure the Participants VC and tab bar item
        GMOParticipantsViewController *participantsController = [[GMOParticipantsViewController alloc] initWithNibName:@"GMOParticipantsViewController" bundle:[NSBundle mainBundle]];
        participantsController.title = @"People";
        selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"participants"]
                              andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
        tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"participants"]
                            andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
        [participantsController.tabBarItem setFinishedSelectedImage:selectedIcon
                                        withFinishedUnselectedImage:tabBarIcon];
        
        // Create and configure the Grades VC and tab bar item
        GradesViewController *gradesController = [[GradesViewController alloc] initWithNibName:@"GradesViewController" bundle:[NSBundle mainBundle]];
        gradesController.title = @"Grades";
        selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"grades"]
                              andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
        tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"grades"]
                            andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
        [gradesController.tabBarItem setFinishedSelectedImage:selectedIcon
                                  withFinishedUnselectedImage:tabBarIcon];
        
        // Create and configure the Forums VC and tab bar item
        ForumViewController *forumController = [[ForumViewController alloc] initWithNibName:@"ForumViewController" bundle:[NSBundle mainBundle]];
        forumController.title = @"Forums";
        selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"forums"]
                              andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
        tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"forums"]
                            andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
        [forumController.tabBarItem setFinishedSelectedImage:selectedIcon
                                 withFinishedUnselectedImage:tabBarIcon];

        /* Since the iPad tab bar background doesn't have the vertical lines (because the tab bar items don't line
           up cleanly – it's complicated), set the background and selection indicator image for the device we're
           running on */
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"ipadtabbarbackground"]];
            [[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"ipadtabbarselection"]];
        } else {
            [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"tabbarbackground"]];
            [[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbarselection"]];
        }
        
        // Set the regular and selected text attributes for all of the tab bar items
        [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor       : [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0],
                                                             UITextAttributeTextShadowColor : [UIColor blackColor],
                                                            UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, -1.0f)] }
                                                 forState:UIControlStateNormal];
       
        [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor        : [UIColor whiteColor],
                                                             UITextAttributeTextShadowColor  : [UIColor blackColor],
                                                             UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)] }
                                                 forState:UIControlStateSelected];
    
        [self setViewControllers:@[ dashboardController, assignmentsController, participantsController, gradesController, forumController ]];
        
        [dashboardController release];
        [assignmentsController release];
        [participantsController release];
        [gradesController release];
        [forumController release];
    }
    
    return self;
}

- (UIImage *)tabBarIconWithImage:(UIImage *)img andGradientOverlay:(UIImage *)gradient {
    // Create a 34x34 graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(34, 34), NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Draw the gradient we're passed over the center 30x30 points
    CGContextDrawImage(context, CGRectMake(2, 2, 30, 30), gradient.CGImage);
    // Composite our image atop it such that the gradient is masked to the image
    [img drawAtPoint:CGPointMake(2, 2) blendMode:kCGBlendModeDestinationAtop alpha:1.0];

    // Grab the current image from the graphics context
    UIImage *pic = UIGraphicsGetImageFromCurrentImageContext();
    
    // Clear out the context
    CGContextClearRect(context, CGRectMake(0, 0, 34, 34));
    // Set a 2 pixel black shadow
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 2, [UIColor blackColor].CGColor);
    // Draw the previous contents of the context (the gradient masked to the image) with the shadow we just set
    CGContextDrawImage(context, CGRectMake(0, 0, 34, 34), pic.CGImage);
    // Get the final image and destroy the context
    pic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Scale and rotate the final image so it appears right-side-up and retina (or not) as needed
    pic = [UIImage imageWithCGImage:[pic CGImage] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDownMirrored];
    
    return pic;

}

// Allow rotation on the iPad and enforce portrait orientation on other devices
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

@end
