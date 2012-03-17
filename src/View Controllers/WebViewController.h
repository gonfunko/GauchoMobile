//
//  WebViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface WebViewController : UIViewController <UIWebViewDelegate> {
@private
    IBOutlet UIWebView *webView;
    NSURL *pendingURL;
    
    MBProgressHUD *HUD;
}

//Loads a given URL in the web view
- (void)loadURL:(NSURL *)url;
- (IBAction)openInSafari:(id)sender;

@end
