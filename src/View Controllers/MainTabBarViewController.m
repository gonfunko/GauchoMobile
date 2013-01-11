//
//  MainTabBarViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/15/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "MainTabBarViewController.h"

#define kTabBarItemTextColor [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0]

@implementation MainTabBarViewController

- (id)init {
    if (self = [super init]) {
        //Create our view controllers and add them to the tab bar controller
        DashboardViewController *dashboardController = [[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:[NSBundle mainBundle]];
        dashboardController.title = @"Dashboard";
        dashboardController.tabBarItem.image = [UIImage imageNamed:@"dashboard"];
        
        UIViewController *assignmentsController;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            assignmentsController = [[AssignmentsViewController alloc] initWithNibName:@"AssignmentsViewController" bundle:[NSBundle mainBundle]];
        } else {
            assignmentsController = [[GMiPadAssignmentsViewController alloc] initWithNibName:@"GMiPadAssignmentsViewController" bundle:[NSBundle mainBundle]];
        }
        assignmentsController.title = @"Assignments";
        assignmentsController.tabBarItem.image = [UIImage imageNamed:@"assignments"];

        
        UIViewController *participantsController = [[GMParticipantsViewController alloc] initWithNibName:@"GMParticipantsViewController" bundle:[NSBundle mainBundle]];
        participantsController.title = @"People";
        participantsController.tabBarItem.image = [UIImage imageNamed:@"participants"];
        
        GradesViewController *gradesController = [[GradesViewController alloc] initWithNibName:@"GradesViewController" bundle:[NSBundle mainBundle]];
        gradesController.title = @"Grades";
        gradesController.tabBarItem.image = [UIImage imageNamed:@"grades"];
        
        ForumViewController *forumController = [[ForumViewController alloc] initWithNibName:@"ForumViewController" bundle:[NSBundle mainBundle]];
        forumController.title = @"Forums";
        forumController.tabBarItem.image = [UIImage imageNamed:@"forums"];

        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"ipadtabbarbackground"]];
                [[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"ipadtabbarselection"]];
            } else {
                [[self tabBar] setBackgroundImage:[UIImage imageNamed:@"tabbarbackground"]];
                [[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbarselection"]];
            }
            
            UIImage *selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"dashboard"]
                                           andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
            UIImage *tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"dashboard"]
                                         andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
            [dashboardController.tabBarItem setFinishedSelectedImage:selectedIcon
                                         withFinishedUnselectedImage:tabBarIcon];
            [dashboardController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : kTabBarItemTextColor,
                                                                      UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                      UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, -1.0f)] }
                                                          forState:UIControlStateNormal];
            [dashboardController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor],
                                                                      UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                      UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)] }
                                                          forState:UIControlStateSelected];
            
            selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"assignments"]
                                  andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
            tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"assignments"]
                                andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
            [assignmentsController.tabBarItem setFinishedSelectedImage:selectedIcon
                                           withFinishedUnselectedImage:tabBarIcon];
            [assignmentsController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : kTabBarItemTextColor,
                                                                        UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                        UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, -1.0f)] }
                                                            forState:UIControlStateNormal];
            [assignmentsController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor],
                                                                        UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                        UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)] }
                                                            forState:UIControlStateSelected];
            
            selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"participants"]
                                  andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
            tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"participants"]
                                andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
            [participantsController.tabBarItem setFinishedSelectedImage:selectedIcon
                                            withFinishedUnselectedImage:tabBarIcon];
            [participantsController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : kTabBarItemTextColor,
                                                                         UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                         UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, -1.0f)] }
                                                             forState:UIControlStateNormal];
            [participantsController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor],
                                                                         UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                         UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)] }
                                                             forState:UIControlStateSelected];
            
            selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"grades"]
                                  andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
            tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"grades"]
                                andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
            [gradesController.tabBarItem setFinishedSelectedImage:selectedIcon
                                      withFinishedUnselectedImage:tabBarIcon];
            [gradesController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : kTabBarItemTextColor,
                                                                   UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                   UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, -1.0f)] }
                                                       forState:UIControlStateNormal];
            [gradesController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor],
                                                                   UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                   UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)] }
                                                       forState:UIControlStateSelected];

            selectedIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"forums"]
                                  andGradientOverlay:[UIImage imageNamed:@"selectedtabbaritemgradient"]];
            tabBarIcon = [self tabBarIconWithImage:[UIImage imageNamed:@"forums"]
                                andGradientOverlay:[UIImage imageNamed:@"tabbaritemgradient"]];
            [forumController.tabBarItem setFinishedSelectedImage:selectedIcon
                                      withFinishedUnselectedImage:tabBarIcon];
            [forumController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : kTabBarItemTextColor,
                                                                  UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                  UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, -1.0f)] }
                                                      forState:UIControlStateNormal];
            [forumController.tabBarItem setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor],
                                                                  UITextAttributeTextShadowColor : [UIColor blackColor],
                                                                  UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)] }
                                                      forState:UIControlStateSelected];
        }
        
        self.navigationItem.title = @"Dashboard";
        [self setViewControllers:[NSArray arrayWithObjects:dashboardController, assignmentsController, participantsController, gradesController, forumController, nil]];
        
        [dashboardController release];
        [assignmentsController release];
        [participantsController release];
        [gradesController release];
        [forumController release];
    }
    
    return self;
}

- (UIImage *)tabBarIconWithImage:(UIImage *)img andGradientOverlay:(UIImage *)gradient {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(34, 34), NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, CGRectMake(2, 2, 30, 30), gradient.CGImage);
    [img drawAtPoint:CGPointMake(2, 2) blendMode:kCGBlendModeDestinationAtop alpha:1.0];
    UIImage * pic = UIGraphicsGetImageFromCurrentImageContext();
    CGContextClearRect(context, CGRectMake(0, 0, 34, 34));
    CGContextSetShadowWithColor(context, CGSizeMake(0,0), 2, [UIColor blackColor].CGColor);
    CGContextDrawImage(context, CGRectMake(0, 0, 34, 34), pic.CGImage);
    pic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    pic = [UIImage imageWithCGImage:[pic CGImage] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDownMirrored];
    
    return pic;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

@end
