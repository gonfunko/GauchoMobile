//
//  AssignmentsListViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 12/16/12.
//
//

#import "AssignmentsListViewController.h"

@implementation AssignmentsListViewController

- (void)viewDidLoad {
    self.tableView.scrollsToTop = YES;
    pendingID = 0;
    
    noAssignmentsLabel = [[UITextField alloc] initWithFrame:[self.tableView boundsForPlaceholderLabel]];
    noAssignmentsLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    noAssignmentsLabel.enabled = NO;
    noAssignmentsLabel.text = @"No Assignments";
    noAssignmentsLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    noAssignmentsLabel.textColor = [UIColor grayColor];
    noAssignmentsLabel.textAlignment = UITextAlignmentCenter;
    noAssignmentsLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    noAssignmentsLabel.hidden = YES;
    [self.tableView addSubview:noAssignmentsLabel];
    [noAssignmentsLabel release];
    
    fetcher = [[GMSourceFetcher alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(loadAssignments)
             forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;
    
    [refreshControl release];
}

- (void)loadAssignments {
    if (!self.refreshControl.isRefreshing) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
    }
        
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    [fetcher assignmentsForCourse:currentCourse withDelegate:self];
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading assignments failed with error: %@", [error description]);
    [self.refreshControl endRefreshing];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    
    [[[GMDataSource sharedDataSource] currentCourse] removeAllAssignments];
    
    GMAssignmentsParser *parser = [[GMAssignmentsParser alloc] init];
    NSArray *assignments = [parser assignmentsFromSource:source];
    
    for (GMAssignment *assignment in assignments) {
        [[[GMDataSource sharedDataSource] currentCourse] addAssignment:assignment];
    }
    
    [parser release];
    
    [self.tableView reloadData];
    
    if (pendingID != 0) {
        [self showAssignmentWithID:[NSNumber numberWithInteger:pendingID]];
        pendingID = 0;
    }
    
    [self.refreshControl endRefreshing];
}

- (void)viewDidLayoutSubviews {
    noAssignmentsLabel.frame = [self.tableView boundsForPlaceholderLabel];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [[[[GMDataSource sharedDataSource] currentCourse] assignments] count];
    
    if (rows == 0) {
        noAssignmentsLabel.hidden = NO;
    } else {
        noAssignmentsLabel.hidden = YES;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GMAssignment *assignment = [[[[GMDataSource sharedDataSource] currentCourse] assignments] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = assignment.description;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 25);
    button.layer.cornerRadius = 5.0;
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1.0);
    
    NSInteger offset = [[NSTimeZone localTimeZone] secondsFromGMTForDate:[NSDate date]];
    NSDate *now = [[NSDate date] dateByAddingTimeInterval:offset];
    if (assignment.submittedDate != nil) {
        [button setTitle:@"DONE" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor grayColor];
    } else if (assignment.dueDate != nil && [[assignment.dueDate earlierDate:now] isEqualToDate:assignment.dueDate]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"M/d"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [button setTitle:[NSString stringWithFormat:@"DUE %@", [formatter stringFromDate:assignment.dueDate]] forState:UIControlStateNormal];
        [formatter release];
        button.backgroundColor = [UIColor colorWithRed:163/255.0 green:0.0 blue:6.0/255.0 alpha:1.0];
        [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    } else if (assignment.dueDate != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"M/d"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [button setTitle:[NSString stringWithFormat:@"DUE %@", [formatter stringFromDate:assignment.dueDate]] forState:UIControlStateNormal];
        [formatter release];
        button.backgroundColor = [UIColor colorWithRed:0.0 green:139/255.0 blue:15.0/255.0 alpha:1.0];
        [button addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:@"" forState:UIControlStateNormal];
    }
    
    cell.accessoryView = button;
    
    return cell;
}

- (void)accessoryButtonTapped:(UIButton *)button withEvent:(UIEvent *)event
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView:self.tableView]];
    if (indexPath == nil)
        return;
    
    GMAssignment *assignment = [[[[GMDataSource sharedDataSource] currentCourse] assignments] objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSString *newString = @"";
    
    if ([[button titleForState:UIControlStateNormal] rangeOfString:@":"].location == NSNotFound) {
        [formatter setDateFormat:@"h:mm a"];
        newString = [formatter stringFromDate:assignment.dueDate];
    } else {
        [formatter setDateFormat:@"M/d"];
        newString = [NSString stringWithFormat:@"DUE %@", [formatter stringFromDate:assignment.dueDate]];
    }
    
    [button setTitle:newString forState:UIControlStateNormal];
    [formatter release];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMAssignment *assignment = [[[[GMDataSource sharedDataSource] currentCourse] assignments] objectAtIndex:indexPath.row];
    
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
    
    AssignmentDetailViewController *details = [[AssignmentDetailViewController alloc] initWithNibName:@"AssignmentDetailViewController" bundle:[NSBundle mainBundle]];
    details.assignment = assignment;
    details.tabBarController = (UITabBarController *)(self.navigationController.visibleViewController);
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:details animated:YES];
        [details release];
    } else {
        UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:details];
        detailNav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:detailNav animated:YES];
        [details release];
        [detailNav release];
    }
}

#pragma mark - Animation methods

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if ([theAnimation valueForKey:@"layer"] != nil) {
        [(CALayer *)[theAnimation valueForKey:@"layer"] removeFromSuperlayer];
    }
}

- (void)showAssignmentWithID:(NSNumber *)assignmentID {
    if ([[[[GMDataSource sharedDataSource] currentCourse] assignments] count] != 0) {
        
        NSArray *assignments = [[[GMDataSource sharedDataSource] currentCourse] assignments];
        
        for (int i = 0; i < [assignments count]; i++) {
            if (((GMAssignment *)[assignments objectAtIndex:i]).assignmentID == [assignmentID integerValue]) {
                GMAssignment *assignment = [assignments objectAtIndex:i];
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                
                CAGradientLayer *layer = [[CAGradientLayer alloc] init];
                
                CGColorRef first = [[UIColor colorWithRed:242/255.0 green:206/255.0 blue:68/255.0 alpha:1.0] CGColor];
                CGColorRef second = [[UIColor colorWithRed:239/255.0 green:172/255.0 blue:30/255.0 alpha:1.0] CGColor];
                
                layer.colors = [NSArray arrayWithObjects:(id)first, (id)second, nil];
                layer.cornerRadius = 15.0;
                layer.borderWidth = 1.0;
                layer.borderColor = [[UIColor grayColor] CGColor];
                layer.frame = CGRectMake(0, i * 44, [self.tableView frame].size.width, 44);
                [self.tableView.layer addSublayer:layer];
                [layer release];
                
                CATextLayer *description = [[CATextLayer alloc] init];
                description.frame = CGRectMake(10, 14, layer.frame.size.width - 20, layer.frame.size.height - 10);
                CGFontRef descriptionFont = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica-Bold" size:18.0].fontName);
                description.font = descriptionFont;
                CGFontRelease(descriptionFont);
                description.fontSize = 18.0;
                description.foregroundColor = [[UIColor blackColor] CGColor];
                description.contentsScale = [[UIScreen mainScreen] scale];
                description.string = assignment.description;
                [layer addSublayer:description];
                [description release];
                
                //From http://stackoverflow.com/questions/2690775/creating-a-pop-animation-similar-to-the-presentation-of-uialertview
                CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                                  animationWithKeyPath:@"transform"];
                
                CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
                CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
                CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
                CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
                
                NSArray *frameValues = [NSArray arrayWithObjects:
                                        [NSValue valueWithCATransform3D:scale1],
                                        [NSValue valueWithCATransform3D:scale2],
                                        [NSValue valueWithCATransform3D:scale3],
                                        [NSValue valueWithCATransform3D:scale4],
                                        nil];
                [animation setValues:frameValues];
                
                NSArray *frameTimes = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0],
                                       [NSNumber numberWithFloat:0.5],
                                       [NSNumber numberWithFloat:0.9],
                                       [NSNumber numberWithFloat:1.0],
                                       nil];
                [animation setKeyTimes:frameTimes];
                
                animation.fillMode = kCAFillModeForwards;
                animation.removedOnCompletion = NO;
                animation.duration = .4;
                animation.delegate = self;
                [animation setValue:layer forKey:@"layer"];
                
                [layer addAnimation:animation forKey:@"popup"];
                
                return;
            }
        }
    } else {
        pendingID = [assignmentID integerValue];
    }
}


@end
