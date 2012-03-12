//
//  GMCourseViewController.h
//  Handles presentation and interaction with the list of courses
//  Created by Group J5 for CS48
//

#import <UIKit/UIKit.h>
#import "GMDataSource.h"
#import "DashboardViewController.h"
#import "AssignmentsViewController.h"
#import "ParticipantsViewController.h"
#import "GradesViewController.h"
#import "LoginViewController.h"
#import "ForumViewController.h"
#import "GMSourceFetcher.h"
#import "KeychainItemWrapper.h"

@interface CourseViewController : UITableViewController {
@private
    GMSourceFetcher *fetcher;
}

@end
