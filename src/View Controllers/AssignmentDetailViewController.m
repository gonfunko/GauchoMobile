//
//  AssignmentDetailViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 1/15/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "AssignmentDetailViewController.h"

@implementation AssignmentDetailViewController

@synthesize assignment;
@synthesize details;
@synthesize tabBarController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    details = @"";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        sizingWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
    } else {
        sizingWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 474, 100)];
    }
    
    sizingWebView.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"Details";
    self.tableView.allowsSelection = NO;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(loadAssignmentDetails)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [refreshControl release];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
    }

    fetcher = [[GMSourceFetcher alloc] init];
    [self loadAssignmentDetails];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)loadAssignmentDetails {
    if (!self.refreshControl.isRefreshing) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
    }
    
    [fetcher detailsForAssignment:self.assignment withDelegate:self];
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Fetching assignment details failed with error: %@", [error description]);
    [self.refreshControl endRefreshing];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    GMAssignmentDetailsParser *parser = [[GMAssignmentDetailsParser alloc] init];
    NSDictionary *results = [[parser assignmentDetailsFromSource:source] retain];
    [parser release];
    self.details = [NSString stringWithFormat:@"<html> \n"
                                                  "<head> \n"
                                                  "<style type=\"text/css\"> \n"
                                                  "body {font-family: \"%@\";}\n"
                                                  "</style> \n"
                                                  "</head> \n"
                                                  "<body>%@</body> \n"
                                                  "</html>", @"helvetica", [results objectForKey:@"details"]];
    [results release];
    
    [sizingWebView loadHTMLString:self.details baseURL:[NSURL URLWithString:@"https://gauchospace.ucsb.edu"]];
    [self.refreshControl endRefreshing];
}

- (void)webViewDidFinishLoad:(UIWebView *)view {
    if ([view isEqual:sizingWebView]) {
        webviewHeight = [[view stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] intValue];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"text"];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"webview"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttons"];
    }
    
    if (cell == nil) {
        if (indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1)) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"text"] autorelease];
        } else if (indexPath.section == 0 && indexPath.row == 2) {
            cell = [[[GMWebViewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"webview"] autorelease];
        } else {
            cell = [[[GMTwoButtonTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"buttons"] autorelease];
        }
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (self.assignment.dueDate != nil) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMMM dd h:mm a"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            NSString *dueDate = [formatter stringFromDate:self.assignment.dueDate];
            [formatter release];
            cell.textLabel.text = [NSString stringWithFormat:@"Due: %@", dueDate];
        } else {
            cell.textLabel.text = @"Due: –";
        }
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        if (self.assignment.submittedDate != nil) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMMM dd h:mm a"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            NSString *submittedDate = [formatter stringFromDate:self.assignment.submittedDate];
            [formatter release];
            cell.textLabel.text = [NSString stringWithFormat:@"Submitted: %@", submittedDate];
        } else {
            cell.textLabel.text = @"Submitted: –";
        }
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        [((GMWebViewTableCell *)cell).webview loadHTMLString:details baseURL:[NSURL URLWithString:@"https://gauchospace.ucsb.edu"]];
        ((GMWebViewTableCell *)cell).webview.delegate = self;
    } else if (indexPath.section == 1) {
        [((GMTwoButtonTableCell *)cell).firstButton setTitle:@"View Grade"
                                                    forState:UIControlStateNormal];
        [((GMTwoButtonTableCell *)cell).firstButton addTarget:self
                                                       action:@selector(showGrade:)
                                             forControlEvents:UIControlEventTouchUpInside];
        
        [((GMTwoButtonTableCell *)cell).secondButton setTitle:@"Print"
                                                     forState:UIControlStateNormal];
        [((GMTwoButtonTableCell *)cell).secondButton addTarget:self
                                                        action:@selector(printAssignment:)
                                              forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.assignment.description;
    } else {
        return @"";
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 2) {
        return MAX(webviewHeight, tableView.rowHeight);
    } else {
        return tableView.rowHeight;
    }
}

- (void)showGrade:(id)sender {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        void (^completionHandler)(void) = ^() {};
        [self dismissViewControllerAnimated:YES completion:completionHandler];
    }
    tabBarController.selectedViewController = [[tabBarController viewControllers] objectAtIndex:3];
    [[[tabBarController viewControllers] objectAtIndex:3] performSelector:@selector(showGradeWithID:) withObject:[NSNumber numberWithInteger:self.assignment.assignmentID]];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)printAssignment:(id)sender {
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0]];
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    pic.printInfo = printInfo;
    pic.printFormatter = [sizingWebView viewPrintFormatter];
    pic.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {};
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [pic presentAnimated:YES completionHandler:completionHandler];
    } else {
        [pic presentFromRect:[sender frame] inView:[sender superview] animated:YES completionHandler:completionHandler];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([webView isEqual:sizingWebView]) {
        return YES;
    } else {
        if ([[[request URL] absoluteString] isEqualToString:@"https://gauchospace.ucsb.edu/"]) {
            return YES;
        } else {
            WebViewController *controller = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]];
            [controller loadURL:[request URL]];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            return NO;
        }
    }
}

- (void)dealloc {
    sizingWebView.delegate = nil;
    self.assignment = nil;
    [super dealloc];
}

@end
