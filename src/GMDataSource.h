//
//  GMDataSource.h
//  Singleton class that manages data model objects
//  Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>
#import "GMCourse.h"

@interface GMDataSource : NSObject {
@private
    NSMutableArray *courses;
    NSString *username;
    NSString *password;
    GMCourse *currentCourse;
}

@property (retain) GMCourse *currentCourse;
@property (copy) NSString *username;
@property (copy) NSString *password;

//Returns the only instance of the data source
+ (id)sharedDataSource;

//Adds a GMCourse object to the data source
- (void)addCourse:(GMCourse *)newCourse;

//Removes all courses currently stored in the data source; essentially resets it
- (void)removeAllCourses;

//Returns an array of all GMCourse objects managed by the data source
- (NSArray *)allCourses;

//Writes all active data to disk
- (void)archiveData;

//Attempts to restore data from disk; returns TRUE on success, FALSE on failure
- (BOOL)restoreData;

@end
