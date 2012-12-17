//
//  WebViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate> {
@private
    IBOutlet UIWebView *webView;
    IBOutlet UIBarButtonItem *actionButton;
    NSURL *pendingURL;
    
    MBProgressHUD *HUD;
}

//Loads a given URL in the web view
- (void)loadURL:(NSURL *)url;
- (IBAction)showActionSheet:(id)sender;

@end
