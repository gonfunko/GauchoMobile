//
//  GradesViewController.m
//  Handles presentation and interaction with the list of grades
//  Created by Group J5 for CS48
//

#import "GradesViewController.h"

@implementation GradesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadGrades)
                                                     name:@"GMCurrentCourseChangedNotification"
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"GMCurrentCourseChangedNotification"
                                                  object:nil];
    [fetcher release];
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
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.tabBarController.navigationItem.title = @"Grades";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(loadGrades)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [refreshControl release];
    
    noGradesLabel = [[UITextField alloc] initWithFrame:[self.tableView boundsForPlaceholderLabel]];
    noGradesLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    noGradesLabel.hidden = YES;
    noGradesLabel.text = @"No Grades";
    noGradesLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
    noGradesLabel.textColor = [UIColor grayColor];
    noGradesLabel.textAlignment = UITextAlignmentCenter;
    noGradesLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    noGradesLabel.userInteractionEnabled = NO;
    [self.tableView addSubview:noGradesLabel];
    [noGradesLabel release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.tabBarController.navigationItem.title = @"Grades";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    
    noGradesLabel.frame = [self.tableView boundsForPlaceholderLabel];
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    fetcher = [[GMSourceFetcher alloc] init];
    
    if ([[currentCourse grades] count] == 0) {
        [self loadGrades];
    }
    
    pendingID = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    noGradesLabel.frame = [self.tableView boundsForPlaceholderLabel];
}

#pragma mark - Data loading methods

- (void)loadGrades {
    if (!self.refreshControl.isRefreshing) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
    }

    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    [fetcher gradesForCourse:currentCourse withDelegate:self];
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    NSLog(@"Loading grades failed with error: %@", [error description]);

    [self.refreshControl endRefreshing];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    [[[GMDataSource sharedDataSource] currentCourse] removeAllGrades];

    GMGradesParser *parser = [[GMGradesParser alloc] init];
    NSArray *grades = [parser gradesFromSource:source];
    
    for (GMGrade *grade in grades) {
        [[[GMDataSource sharedDataSource] currentCourse] addGrade:grade];
    }
    
    [parser release];
    
    [self.tableView reloadData];
    
    if ([grades count] == 0) {
        noGradesLabel.hidden = NO;
    } else {
        noGradesLabel.hidden = YES;
    }
    
    if (pendingID != 0) {
        [self showGradeWithID:[NSNumber numberWithInteger:pendingID]];
        pendingID = 0;
    }
    
    [self.refreshControl endRefreshing];
}

#pragma mark - Animation methods

- (void)showGradeWithID:(NSNumber *)gradeID {
    if ([[[[GMDataSource sharedDataSource] currentCourse] grades] count] != 0) {
        
        NSArray *grades = [[[GMDataSource sharedDataSource] currentCourse] grades];
        
        for (int i = 0; i < [grades count]; i++) {
            if (((GMGrade *)[grades objectAtIndex:i]).gradeID == [gradeID integerValue]) {
                GMGrade *grade = [grades objectAtIndex:i];
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                
                CAGradientLayer *layer = [[CAGradientLayer alloc] init];
                
                CGColorRef first = [[UIColor colorWithRed:242/255.0 green:206/255.0 blue:68/255.0 alpha:1.0] CGColor];
                CGColorRef second = [[UIColor colorWithRed:239/255.0 green:172/255.0 blue:30/255.0 alpha:1.0] CGColor];
                
                layer.colors = [NSArray arrayWithObjects:(id)first, (id)second, nil];
                layer.cornerRadius = 15.0;
                layer.borderWidth = 1.0;
                layer.borderColor = [[UIColor grayColor] CGColor];
                layer.frame = CGRectMake(0, i * 50, [self.tableView frame].size.width, 50);
                [self.tableView.layer addSublayer:layer];
                [layer release];
                
                CATextLayer *percentage = [[CATextLayer alloc] init];
                percentage.frame = CGRectMake(10, 11, layer.frame.size.width - 20, layer.frame.size.height - 10);
                CGFontRef percentageFont = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica-Bold" size:30.0].fontName);
                percentage.font = percentageFont;
                CGFontRelease(percentageFont);
                percentage.fontSize = 30.0;
                percentage.foregroundColor = [[UIColor blackColor] CGColor];
                percentage.contentsScale = [[UIScreen mainScreen] scale];
                if (grade.score != -1 && grade.max != 0) {
                    percentage.string = [NSString stringWithFormat:@"%i%%", (int)((double)grade.score / (double)grade.max * 100.0)];
                } else if (grade.score != -1) {
                    percentage.string = [NSString stringWithFormat:@"%i%%", grade.score];
                } else {
                    percentage.string = @"–";
                }
                [layer addSublayer:percentage];
                [percentage release];
                
                CATextLayer *description = [[CATextLayer alloc] init];
                description.frame = CGRectMake(100, 8, layer.frame.size.width - 80, 30);
                CGFontRef descriptionFont = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica-Bold" size:18.0].fontName);
                description.font = descriptionFont;
                CGFontRelease(descriptionFont);
                description.fontSize = 18.0;
                description.foregroundColor = [[UIColor blackColor] CGColor];
                description.contentsScale = [[UIScreen mainScreen] scale];
                description.string = grade.description;
                [layer addSublayer:description];
                [description release];
                
                CATextLayer *outof = [[CATextLayer alloc] init];
                outof.frame = CGRectMake(100, 30, layer.frame.size.width - 80, 14);
                CGFontRef outofFont = CGFontCreateWithFontName((CFStringRef)[UIFont fontWithName:@"Helvetica" size:12.0].fontName);
                outof.font = outofFont;
                CGFontRelease(outofFont);
                outof.fontSize = 12.0;
                outof.foregroundColor = [[UIColor grayColor] CGColor];
                outof.contentsScale = [[UIScreen mainScreen] scale];
                if (grade.score != -1 && grade.max != 0) {
                    outof.string = [NSString stringWithFormat:@"%i out of %i", grade.score, grade.max];
                } else if (grade.score != -1) {
                    outof.string = [NSString stringWithFormat:@"%i out of 100", grade.score];
                } else {
                    outof.string = @"Not Graded";
                }
                [layer addSublayer:outof];
                [outof release];
                
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
        pendingID = [gradeID integerValue];
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if ([theAnimation valueForKey:@"layer"] != nil) {
        [(CALayer *)[theAnimation valueForKey:@"layer"] removeFromSuperlayer];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [[[[GMDataSource sharedDataSource] currentCourse] grades] count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    GMGradesTableViewCell *cell = (GMGradesTableViewCell *)[table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GMGradesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GMGrade *grades = [[[[GMDataSource sharedDataSource] currentCourse] grades] objectAtIndex:indexPath.row];
    cell.description.text = grades.description;
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (grades.score == -1){
        cell.percentage.text = @"–";
        cell.outof.text = @"Not Graded";   
    }
    else {
        if (grades.max != 0) {
            cell.percentage.text = [NSString stringWithFormat:@"%i%%", (int)((double)grades.score / (double)grades.max * 100.0)];
            cell.outof.text = [NSString stringWithFormat:@"%i out of %i", grades.score, grades.max];
        } else { // If we don't have a range, just assume it's out of 100
            cell.percentage.text = [NSString stringWithFormat:@"%i%%", grades.score];
            cell.outof.text = [NSString stringWithFormat:@"%i out of 100", grades.score];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMGrade *grade = [[[[GMDataSource sharedDataSource] currentCourse] grades] objectAtIndex:indexPath.row];
    
    UITabBarController *controller = (UITabBarController *)(self.navigationController.visibleViewController);
    controller.selectedViewController = [[controller viewControllers] objectAtIndex:1];
    [[[controller viewControllers] objectAtIndex:1] performSelector:@selector(showAssignmentWithID:) withObject:[NSNumber numberWithInteger:grade.gradeID]];
    
    [table deselectRowAtIndexPath:indexPath animated:YES];
}

@end
