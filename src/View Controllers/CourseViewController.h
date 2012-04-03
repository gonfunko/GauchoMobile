//
//  GMCourseViewController.h
//  Handles presentation and interaction with the list of courses
//  Created by Group J5 for CS48
//

#import <UIKit/UIKit.h>
#import "GMDataSource.h"
#import "LoginViewController.h"
#import "MainTabBarViewController.h"
#import "GMSourceFetcher.h"
#import "KeychainItemWrapper.h"

@interface CourseViewController : UITableViewController {
@private
    GMSourceFetcher *fetcher;
}

- (void)selectCurrentCourse;

@end
