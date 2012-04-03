//
//  MainTabBarViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/15/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "MainTabBarViewController.h"

@implementation MainTabBarViewController

- (id)init {
    if (self = [super init]) {
        //Create our view controllers and add them to the tab bar controller
        DashboardViewController *dashboardController = [[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:[NSBundle mainBundle]];
        dashboardController.title = @"Dashboard";
        dashboardController.tabBarItem.image = [UIImage imageNamed:@"dashboard.png"];
        
        UIViewController *assignmentsController;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            assignmentsController = [[AssignmentsViewController alloc] initWithNibName:@"AssignmentsViewController" bundle:[NSBundle mainBundle]];
        } else {
            assignmentsController = [[GMiPadAssignmentsViewController alloc] initWithNibName:@"GMiPadAssignmentsViewController" bundle:[NSBundle mainBundle]];
        }
        
        assignmentsController.title = @"Assignments";
        assignmentsController.tabBarItem.image = [UIImage imageNamed:@"assignments.png"];
        
        ParticipantsViewController *participantsController = [[ParticipantsViewController alloc] initWithNibName:@"ParticipantsViewController" bundle:[NSBundle mainBundle]];
        participantsController.title = @"People";
        participantsController.tabBarItem.image = [UIImage imageNamed:@"participants.png"];
        
        GradesViewController *gradesController = [[GradesViewController alloc] initWithNibName:@"GradesViewController" bundle:[NSBundle mainBundle]];
        gradesController.title = @"Grades";
        gradesController.tabBarItem.image = [UIImage imageNamed:@"grades.png"];
        
        ForumViewController *forumController = [[ForumViewController alloc] initWithNibName:@"ForumViewController" bundle:[NSBundle mainBundle]];
        forumController.title = @"Forums";
        forumController.tabBarItem.image = [UIImage imageNamed:@"forums.png"];
        
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

@end
