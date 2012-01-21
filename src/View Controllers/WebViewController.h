//
//  WebViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMLoadingView.h"

@interface WebViewController : UIViewController <UIWebViewDelegate> {
@private
    IBOutlet UIWebView *webView;
    NSURL *pendingURL;
    
    GMLoadingView *loadingView;
}

//Loads a given URL in the web view
- (void)loadURL:(NSURL *)url;
- (IBAction)openInSafari:(id)sender;

@end
