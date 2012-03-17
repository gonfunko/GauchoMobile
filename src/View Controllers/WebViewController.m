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

- (void)viewWillDisappear:(BOOL)animated {
    [webView stopLoading];
    webView.delegate = nil;   
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
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    [HUD release];
    HUD.labelText = @"Loading";
    HUD.removeFromSuperViewOnHide = YES;
    [HUD show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)view {
    //From http://stackoverflow.com/questions/2275876/how-to-get-the-title-of-a-html-page-displayed-in-uiwebview
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationController.visibleViewController.navigationItem.title = title;
    
    [HUD hide:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [HUD hide:YES];
}

- (IBAction)openInSafari:(id)sender {
    [[UIApplication sharedApplication] openURL:[webView.request URL]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
