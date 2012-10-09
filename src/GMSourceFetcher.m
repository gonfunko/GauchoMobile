//
//  GMSourceFetcher.m
//  Downloads HTML source code from GauchoSpace
//  Created by Group J5 for CS48
//

#import "GMSourceFetcher.h"

@implementation GMSourceFetcher

- (void)loginWithUsername:(NSString *)username password:(NSString *)password delegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    CFStringRef escapedUsername = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)username, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), kCFStringEncodingUTF8);
    CFStringRef escapedPassword = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)password, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), kCFStringEncodingUTF8);
    NSString *requestString = [NSString stringWithFormat:@"username=%@&password=%@", (NSString *)escapedUsername, (NSString *)escapedPassword];
    NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    CFRelease(escapedUsername);
    CFRelease(escapedPassword);
    
    NSURL *url = [NSURL URLWithString:@"https://gauchospace.ucsb.edu/courses/login/index.php"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:requestData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            NSString *pageContents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [delegate performSelectorOnMainThread:@selector(sourceFetchSucceededWithPageSource:) withObject:pageContents waitUntilDone:YES];
            [pageContents release];
        } else {
            NSLog(@"Error logging in to GauchoSpace: %@", [error description]);
            [delegate performSelectorOnMainThread:@selector(sourceFetchDidFailWithError:) withObject:error waitUntilDone:YES];
        }
    }];
}

- (void)logout {
    NSString *sessionKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionkey"];
    
    NSURL *logoutScriptURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/login/logout.php?sesskey=%@", sessionKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:logoutScriptURL];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data == nil) {
            NSLog(@"Error logging out");
        }
    }];
}

- (void)dashboardForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    int courseID = (int)course.courseID;

    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/course/view.php?id=%i", courseID]];
    [self fetchURL:fetchURL withDelegate:delegate];
}

- (void)assignmentsForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    int courseID = (int)course.courseID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/mod/assignment/index.php?id=%i", courseID]];
    [self fetchURL:fetchURL withDelegate:delegate];
}

- (void)detailsForAssignment:(GMAssignment *)assignment withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    int assignmentID = (int)assignment.assignmentID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/mod/assignment/view.php?id=%i", assignmentID]];
    [self fetchURL:fetchURL withDelegate:delegate];
}

- (void)gradesForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    int courseID = (int)course.courseID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/grade/report/index.php?id=%i", courseID]];
    [self fetchURL:fetchURL withDelegate:delegate];
}

- (void)participantsForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    int courseID = (int)course.courseID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/user/index.php?roleid=0&id=%i&search=&perpage=5000", courseID]];
    [self fetchURL:fetchURL withDelegate:delegate];
}

- (void)forumsForCourse:(GMCourse *)course withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    int courseID = (int)course.courseID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/mod/forum/index.php?id=%i", courseID]];
    [self fetchURL:fetchURL withDelegate:delegate];
}

- (void)topicsForForum:(GMForum *)forum withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    NSString *forumID = forum.forumID;
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/mod/forum/view.php?f=%@", forumID]];
    [self fetchURL:fetchURL withDelegate:delegate];
}

- (void)postsForTopic:(GMForumTopic *)topic withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    int topicID = [topic.topicID intValue];
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://gauchospace.ucsb.edu/courses/mod/forum/discuss.php?d=%i", topicID]];
    [self fetchURL:fetchURL withDelegate:delegate];
}

- (void)fetchURL:(NSURL *)url withDelegate:(NSObject <GMSourceFetcherDelegate> *)delegate {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            NSString *pageContents = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [delegate performSelectorOnMainThread:@selector(sourceFetchSucceededWithPageSource:) withObject:pageContents waitUntilDone:YES];
            [pageContents release];
        } else {
            NSLog(@"Error fetching URL: %@", url.absoluteString);
            [delegate performSelectorOnMainThread:@selector(sourceFetchDidFailWithError:) withObject:error waitUntilDone:YES];
        }
    }];
}

@end
