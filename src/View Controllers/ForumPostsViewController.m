//
//  ForumPostsViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/11/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "ForumPostsViewController.h"

@implementation ForumPostsViewController

@synthesize topic;
@synthesize postsView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.topic = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    if (self.topic == nil) {
        self.navigationController.visibleViewController.navigationItem.title = @"Messages";
    } else {
        self.navigationController.visibleViewController.navigationItem.title = topic.title;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self.navigationController
                                             selector:@selector(popToRootViewControllerAnimated:)
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
    
    fetcher = [[GMSourceFetcher alloc] init];
    
    [((UIScrollView *)self.view) setBackgroundColor:[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0]];
    
    if ([topic.posts count] == 0) {
        [self loadPostsWithLoadingView:YES];
    } else {
        [postsView setPosts:topic.posts];
        [((UIScrollView *)self.view) setContentSize:postsView.frame.size];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)loadPostsWithLoadingView:(BOOL)flag {
    if (!loading) {
        loading = YES;
        
        if (flag) {
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            [HUD release];
            HUD.labelText = @"Loading";
            HUD.removeFromSuperViewOnHide = YES;
            [HUD show:YES];
        }
        
        [fetcher postsForTopic:self.topic withDelegate:self];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading forum posts failed with error: %@", [error description]);
    [HUD hide:YES];
    loading = NO;
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    [HUD hide:YES];
    loading = NO;
    
    GMForumsParser *parser = [[GMForumsParser alloc] init];
    NSArray *posts = [parser forumPostsFromSource:source];  
    topic.posts = posts;
    
    [parser release];
    
    [postsView setPosts:topic.posts];
    [((UIScrollView *)self.view) setContentSize:postsView.frame.size];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.navigationController name:@"GMCurrentCourseChangedNotification" object:nil];
    self.topic = nil;
    [fetcher release];
    [super dealloc];
}

@end
