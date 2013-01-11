//
//  GMDataSource.m
//  Singleton class that manages data model objects
//  Created by Group J5 for CS48
//

#import "GMDataSource.h"


@implementation GMDataSource

@synthesize currentCourse;
@synthesize username;
@synthesize password;

//Implementation of singleton design pattern, based on http://eschatologist.net/blog/?p=178
+ (GMDataSource *)sharedDataSource {
    static id sharedDataSource = nil;
    
    if (sharedDataSource == nil) {
        sharedDataSource = [[self alloc] init];
    }
    
    return sharedDataSource;
}

- (id)init {
    if (self = [super init]) {
        self.currentCourse = nil;
        [self addObserver:self 
               forKeyPath:@"currentCourse" 
                  options:NSKeyValueObservingOptionNew 
                  context:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GMCurrentCourseChangedNotification" 
                                                        object:self.currentCourse];
}

- (void)addCourse:(GMCourse *)newCourse {
    if (courses == nil) {
        courses = [[NSMutableArray alloc] init];
    }
    
    if (![courses containsObject:newCourse]) {
        [courses addObject:newCourse];
    }
}

- (NSArray *)allCourses {
    return courses;
}

- (void)removeAllCourses {
    [courses removeAllObjects];
}

- (BOOL)restoreData {
    //Clear out all information, in case another user was previously logged in
    [self removeAllCourses];
    
    //Determine the cache file path based on the current user and password
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSInteger credentialsHash = [[self.username stringByAppendingString:self.password] hash];
    NSString *path = [[paths objectAtIndex:0] stringByAppendingFormat:@"/data%ld", (long)credentialsHash];
    
    //If the file exists, unarchive the cache and add the courses
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSArray *cachedCourses = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
        for (GMCourse *course in cachedCourses) {
            [self addCourse:course];
        }
        
        [cachedCourses release];
        
        return YES;
    } else {
        return NO;
    }
}

- (void)archiveData {
    //Determine the cache file path based on the current username/password and write it out
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSInteger credentialsHash = [[self.username stringByAppendingString:self.password] hash];
    NSString *path = [[paths objectAtIndex:0] stringByAppendingFormat:@"/data%ld", (long)credentialsHash];
    [NSKeyedArchiver archiveRootObject:courses toFile:path];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"currentCourse"];
    
    self.username = nil;
    self.password = nil;
    self.currentCourse = nil;
    [courses release];
    [super dealloc];
}

@end
