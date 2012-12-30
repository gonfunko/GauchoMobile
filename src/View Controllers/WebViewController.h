//
//  WebViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate> {
@private
    IBOutlet UIWebView *webView;
    IBOutlet UIBarButtonItem *actionButton;
    IBOutlet UIBarButtonItem *backButton;
    IBOutlet UIBarButtonItem *forwardButton;
    IBOutlet UIBarButtonItem *reloadButton;
    IBOutlet UIBarButtonItem *stopButton;
    
    NSURL *pendingURL;
    
    UIActivityIndicatorView *loadingSpinner;
}

//Loads a given URL in the web view
- (void)loadURL:(NSURL *)url;
- (IBAction)showActionSheet:(id)sender;

@end
