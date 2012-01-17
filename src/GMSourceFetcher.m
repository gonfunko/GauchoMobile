//
//  GMSourceFetcher.m
//  Downloads HTML source code from GauchoSpace
//  Created by Group J5 for CS48
//

#import "GMSourceFetcher.h"
#import "ASIFormDataRequest.h"

@implementation GMSourceFetcher

- (id)init {
    if ((self = [super init])) {
    }
    
    return self;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(id<GMSourceFetcherDelegate>)delegate {
    
    NSURL *loginScriptURL = [NSURL URLWithString:@"https://gauchospace.ucsb.edu/courses/login/index.php"];
    ASIFormDataRequest *loginRequest = [ASIFormDataRequest requestWithURL:loginScriptURL];
    [loginRequest setPostValue:username forKey:@"username"];
    [loginRequest setPostValue:password forKey:@"password"];
    [loginRequest setDelegate:self];
    [loginRequest setUserInfo:[NSDictionary dictionaryWithObject:delegate forKey:@"delegate"]];
    [loginRequest startAsynchronous];
}

- (void)logout {
    NSString *sessionKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionkey"];
    
    NSURL *logoutScriptURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/login/logout.php?sesskey=%@", sessionKey]];
    ASIFormDataRequest *logoutRequest = [ASIFormDataRequest requestWithURL:logoutScriptURL];
    [logoutRequest startSynchronous];
}

- (void)dashboardForCourse:(GMCourse *)course withDelegate:(id <GMSourceFetcherDelegate>)delegate {
    int courseID = (int)course.courseID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/course/view.php?id=%i", courseID]];
    
    ASIHTTPRequest *fetchRequest = [ASIHTTPRequest requestWithURL:fetchURL];
    [fetchRequest setUserInfo:[NSDictionary dictionaryWithObject:delegate forKey:@"delegate"]];
    [fetchRequest setDelegate:self];
    [fetchRequest startAsynchronous];
}

- (void)assignmentsForCourse:(GMCourse *)course withDelegate:(id <GMSourceFetcherDelegate>)delegate {
    int courseID = (int)course.courseID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/mod/assignment/index.php?id=%i", courseID]];
    
    ASIHTTPRequest *fetchRequest = [ASIHTTPRequest requestWithURL:fetchURL];
    [fetchRequest setUserInfo:[NSDictionary dictionaryWithObject:delegate forKey:@"delegate"]];
    [fetchRequest setDelegate:self];
    [fetchRequest startAsynchronous];
}

- (void)detailsForAssignment:(GMAssignment *)assignment withDelegate:(id <GMSourceFetcherDelegate>)delegate {
    int assignmentID = (int)assignment.assignmentID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/mod/assignment/view.php?id=%i", assignmentID]];
    
    ASIHTTPRequest *fetchRequest = [ASIHTTPRequest requestWithURL:fetchURL];
    [fetchRequest setUserInfo:[NSDictionary dictionaryWithObject:delegate forKey:@"delegate"]];
    [fetchRequest setDelegate:self];
    [fetchRequest startAsynchronous];
}

- (void)gradesForCourse:(GMCourse *)course withDelegate:(id <GMSourceFetcherDelegate>)delegate {
    int courseID = (int)course.courseID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/grade/report/index.php?id=%i", courseID]];
    
    ASIHTTPRequest *fetchRequest = [ASIHTTPRequest requestWithURL:fetchURL];
    [fetchRequest setUserInfo:[NSDictionary dictionaryWithObject:delegate forKey:@"delegate"]];
    [fetchRequest setDelegate:self];
    [fetchRequest startAsynchronous];
}

- (void)participantsForCourse:(GMCourse *)course withDelegate:(id <GMSourceFetcherDelegate>)delegate {
    int courseID = (int)course.courseID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/user/index.php?roleid=0&id=%i&search=&perpage=5000", courseID]];
    
    ASIHTTPRequest *fetchRequest = [ASIHTTPRequest requestWithURL:fetchURL];
    [fetchRequest setUserInfo:[NSDictionary dictionaryWithObject:delegate forKey:@"delegate"]];
    [fetchRequest setDelegate:self];
    [fetchRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *responseString = [request responseString];
    id <GMSourceFetcherDelegate> delegate = [[request userInfo] objectForKey:@"delegate"];
    [delegate sourceFetchSucceededWithPageSource:responseString];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    
    id <GMSourceFetcherDelegate> delegate = [[request userInfo] objectForKey:@"delegate"];
    [delegate sourceFetchDidFailWithError:error];
}

@end
