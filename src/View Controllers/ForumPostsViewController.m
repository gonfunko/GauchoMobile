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
    
    fetcher = [[GMSourceFetcher alloc] init];
    loadingView = [[GMLoadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, -25, 280, 27)];
    
        [((UIScrollView *)self.view) setBackgroundColor:[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0]];
    
    if ([topic.posts count] == 0) {
        [self loadPostsWithLoadingView:YES];
    } else {
        [postsView setPosts:topic.posts];
        [((UIScrollView *)self.view) setContentSize:postsView.frame.size];
    }
}

- (void)loadPostsWithLoadingView:(BOOL)flag {
    if (!loading) {
        loading = YES;
        
        if (flag) {
            loadingView.hidden = NO;
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
                loadingView.frame = CGRectMake((int)(([[UIScreen mainScreen] bounds].size.height - 280) / 2), -25, 280, 27);
            else
                loadingView.frame = CGRectMake((int)(([[UIScreen mainScreen] bounds].size.width - 280) / 2), -25, 280, 27);
            
            loadingView.layer.zPosition = self.view.layer.zPosition + 1;
            
            [self.view addSubview:loadingView];
            [loadingView release];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, loadingView.layer.position.y + 25)];
            animation.duration = 0.25;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            [[loadingView layer] addAnimation:animation forKey:@"position"];
        }
        
        [fetcher postsForTopic:self.topic withDelegate:self];
    }
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading forum posts failed with error: %@", [error description]);
    loadingView.hidden = YES;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, -25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    loading = NO;
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    loadingView.hidden = YES;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, -25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    loading = NO;
    
    GMForumsParser *parser = [[GMForumsParser alloc] init];
    NSArray *posts = [parser forumPostsFromSource:source];  
    topic.posts = posts;
    
    [parser release];
    
    [postsView setPosts:topic.posts];
    [((UIScrollView *)self.view) setContentSize:postsView.frame.size];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    self.topic = nil;
    [fetcher release];
    [loadingView removeFromSuperview];
    [super dealloc];
}

@end
