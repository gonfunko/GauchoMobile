//
//  AssignmentDetailViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 1/15/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GMAssignment.h"
#import "GMSourceFetcher.h"
#import "GMAssignmentDetailsParser.h"
#import "GMWebViewTableCell.h"
#import "GMTwoButtonTableCell.h"
#import "GMLoadingView.h"
#import "WebViewController.h"

@interface AssignmentDetailViewController : UITableViewController <GMSourceFetcherDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate> {
    GMAssignment *assignment;
    GMLoadingView *loadingView;
    NSString *details;
    UIWebView *sizingWebView;
    int webviewHeight;
}

@property (retain) GMAssignment *assignment;
@property (copy) NSString *details;

@end
