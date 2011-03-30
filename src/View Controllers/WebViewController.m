//
//  WebViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
        
        UIBarButtonItem *openInSafari = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(openInSafari)];
        [openInSafari setStyle:UIBarButtonItemStylePlain];
        
        self.navigationItem.rightBarButtonItem = openInSafari;
        [openInSafari release];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [webView loadRequest:[NSURLRequest requestWithURL:pendingURL]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void)loadURL:(NSURL *)url {
    if ([[url absoluteString] hasPrefix:@"https://gauchospace.ucsb.edu/courses/mod/resource/"])
        pendingURL = [NSURL URLWithString:[[url absoluteString] stringByAppendingString:@"&inpopup=false"]];
    else
        pendingURL = [url copy];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        loadingView = [[GMLoadingView alloc] initWithFrame:CGRectMake((int)(([[UIScreen mainScreen] bounds].size.height - 280) / 2), -25, 280, 27)];
    else
        loadingView = [[GMLoadingView alloc] initWithFrame:CGRectMake((int)(([[UIScreen mainScreen] bounds].size.width - 280) / 2), -25, 280, 27)];
    
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

- (void)webViewDidFinishLoad:(UIWebView *)view {
    //From http://stackoverflow.com/questions/2275876/how-to-get-the-title-of-a-html-page-displayed-in-uiwebview
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationController.visibleViewController.navigationItem.title = title;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, loadingView.layer.position.y - 25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    
    [loadingView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, loadingView.layer.position.y - 25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    
    [loadingView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)openInSafari {
    [[UIApplication sharedApplication] openURL:[webView.request URL]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
