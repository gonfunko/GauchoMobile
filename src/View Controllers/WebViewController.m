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

- (void)webViewDidStartLoad:(UIWebView *)_webView {
    HUD = [[MBProgressHUD alloc] initWithView:webView];
    [self.view addSubview:HUD];
    [HUD release];
    HUD.labelText = @"Loading";
    HUD.removeFromSuperViewOnHide = YES;
    [HUD show:YES];
    
    [self enableToolbarButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)view {
    //From http://stackoverflow.com/questions/2275876/how-to-get-the-title-of-a-html-page-displayed-in-uiwebview
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationController.visibleViewController.navigationItem.title = title;
    
    if (HUD != nil) {
        [HUD hide:YES];
        HUD = nil;
    }
    
    [self enableToolbarButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [HUD hide:YES];
    [self enableToolbarButtons];
}

- (void)enableToolbarButtons {
    [backButton setEnabled:webView.canGoBack];
    [forwardButton setEnabled:webView.canGoForward];
    [stopButton setEnabled:webView.isLoading];
    [reloadButton setEnabled:!webView.isLoading];
    [actionButton setEnabled:!webView.isLoading];
}

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Open in Safari", @"Open In...", nil];
    
    [actionSheet showFromBarButtonItem:actionButton animated:YES];
    
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:webView.request.URL];
    } else if (buttonIndex == 1) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [self showOpenInSheet];
        } else {
            [self performSelector:@selector(showOpenInSheet) withObject:nil afterDelay:1.0];
        }
    }
}

- (void)showOpenInSheet {
    NSCachedURLResponse *currentPage = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    
    if (currentPage) {
        NSString *pagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[currentPage.response.URL lastPathComponent]];
        
        NSError *fileWriteError = nil;
        if ([currentPage.data writeToFile:pagePath
                                  options:NSDataWritingAtomic
                                    error:&fileWriteError]) {
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Share"
                                                            message:@"The contents of this web page could not be shared with other applications"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            
            [alert show];
            [alert release];
            return;
        }
        
        UIDocumentInteractionController *documentController = [[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:pagePath]] retain];
        documentController.delegate = self;
        
        [documentController presentOpenInMenuFromBarButtonItem:actionButton
                                                      animated:YES];
    }
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    if ([[NSFileManager defaultManager] fileExistsAtPath:controller.URL.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:controller.URL error:nil];
    }
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    //This is horrible, and really shouldn't be necessary, but the Internet seems to agree that it is in this case,
    //because if we don't retain the UIDocumentInteractionController (and therefore need to release it here),
    //we'll crash when the user chooses an app to open in.
    [controller release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

@end
