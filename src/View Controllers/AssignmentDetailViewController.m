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
    loadingView = [[GMLoadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, -25, 280, 27)];
    details = @"";
    sizingWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 290, 100)];
    sizingWebView.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.navigationController.visibleViewController.navigationItem.title = @"Details";
    self.tableView.allowsSelection = NO;
    
    loadingView.frame = CGRectMake((int)(([[UIScreen mainScreen] bounds].size.width - 280) / 2), -25, 280, 27);
    
    loadingView.layer.zPosition = self.tableView.layer.zPosition + 1;
    [self.view addSubview:loadingView];
    [loadingView release];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, loadingView.layer.position.y + 25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    
    self.tableView.scrollEnabled = NO;
    
    GMSourceFetcher *fetcher = [[GMSourceFetcher alloc] init];
    [fetcher detailsForAssignment:self.assignment withDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Fetching assignment details failed with error: %@", [error description]);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, -25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    [loadingView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.25];
    self.tableView.scrollEnabled = YES;
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    GMAssignmentDetailsParser *parser = [[GMAssignmentDetailsParser alloc] init];
    NSDictionary *results = [parser assignmentDetailsFromSource:source];
    self.details = [NSString stringWithFormat:@"<html> \n"
                                                  "<head> \n"
                                                  "<style type=\"text/css\"> \n"
                                                  "body {font-family: \"%@\";}\n"
                                                  "</style> \n"
                                                  "</head> \n"
                                                  "<body>%@</body> \n"
                                                  "</html>", @"helvetica", [results objectForKey:@"details"]];
    
    [sizingWebView loadHTMLString:self.details baseURL:[NSURL URLWithString:@"https://gauchospace.ucsb.edu"]];
}

- (void)webViewDidFinishLoad:(UIWebView *)view {
    webviewHeight = [[view stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] intValue];
    [self.tableView reloadData];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, -25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    [loadingView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.25];
    self.tableView.scrollEnabled = YES;
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
            cell.textLabel.text = [NSString stringWithFormat:@"Submitted: %@", submittedDate];
        } else {
            cell.textLabel.text = @"Submitted: –";
        }
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        [((GMWebViewTableCell *)cell).webview loadHTMLString:details baseURL:[NSURL URLWithString:@"https://gauchospace.ucsb.edu"]];
    } else if (indexPath.section == 1) {
        [((GMTwoButtonTableCell *)cell).firstButton setTitle:@"Email" forState:UIControlStateNormal];
        [((GMTwoButtonTableCell *)cell).firstButton setTitle:@"Email" forState:UIControlStateHighlighted];
        [((GMTwoButtonTableCell *)cell).firstButton setTitle:@"Email" forState:UIControlStateSelected];
        [((GMTwoButtonTableCell *)cell).firstButton addTarget:self action:@selector(emailAssignment:) forControlEvents:UIControlEventTouchUpInside];
        [((GMTwoButtonTableCell *)cell).secondButton setTitle:@"Print" forState:UIControlStateNormal];
        [((GMTwoButtonTableCell *)cell).secondButton setTitle:@"Print" forState:UIControlStateHighlighted];
        [((GMTwoButtonTableCell *)cell).secondButton setTitle:@"Print" forState:UIControlStateSelected];
        [((GMTwoButtonTableCell *)cell).secondButton addTarget:self action:@selector(printAssignment:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)emailAssignment:(id)sender {
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    controller.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    [controller setSubject:self.assignment.description];
    [controller setMessageBody:details isHTML:YES]; 
    [self presentModalViewController:controller animated:YES];
    [controller release];
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
    
    [pic presentAnimated:YES completionHandler:completionHandler];
}

- (void)dealloc {
    sizingWebView.delegate = nil;
    [super dealloc];
}

@end
