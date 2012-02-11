//
//  LoginViewController.m
//  Handles presentation and interaction with the login view
//  Created by Group J5 for CS48
//

#import "LoginViewController.h"


@implementation LoginViewController

#pragma mark - View stuff

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        image = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set up the moving pictures in the background
    double ratio = [[UIScreen mainScreen] bounds].size.height / 1024.0;
    floatingBackground = [[CALayer alloc] init];
    floatingBackground.anchorPoint = CGPointMake(0, 0);
    floatingBackground.frame = CGRectMake(0, 0, 1536 * ratio, 1024 * ratio);
    floatingBackground.contents = (id)[[UIImage imageNamed:@"1.jpg"] CGImage];
    floatingBackground.backgroundColor = [[UIColor redColor] CGColor];
    floatingBackground.zPosition = [self.view layer].zPosition - 1;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [floatingBackground valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(-1 * ((1536 * ratio) - [[UIScreen mainScreen] bounds].size.width), 0)];
    animation.duration = 20.0;
    animation.delegate = self;
    
    floatingBackground.position = CGPointMake(-1 * ((1536 * ratio) - [[UIScreen mainScreen] bounds].size.width), 0);
    
    [floatingBackground addAnimation:animation forKey:@"position"];
    [[self.view layer] addSublayer:floatingBackground];
    self.view.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    touchRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:touchRecognizer];
    [touchRecognizer release];
    
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.stuffediggy.gauchomobile" accessGroup:nil];
    
    if ([keychain objectForKey:(id)kSecAttrAccount] != nil) {
        username.text = [keychain objectForKey:(id)kSecAttrAccount];
    }
    if ([keychain objectForKey:(id)kSecValueData] != nil) {
        password.text = [keychain objectForKey:(id)kSecValueData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    loginView.frame = CGRectMake((int)((self.view.frame.size.width - loginView.frame.size.width) / 2), 60, loginView.frame.size.width, loginView.frame.size.height);
    loginView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:loginView];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"loginScreenVisible"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"loginScreenVisible"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [super dealloc];
    [floatingBackground release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Core animation handling

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;
{
    [floatingBackground removeAllAnimations];
    
    image++;
    if (image == 4) //Change this value to add support for more images
        image = 1;
    
    double ratio = [[UIScreen mainScreen] bounds].size.height / 1024.0;
    
    //Determine whether we're going left to right or right to left
    CGPoint newPoint;
    if (CGPointEqualToPoint(floatingBackground.position, CGPointMake(-1 * ((1536 * ratio) - [[UIScreen mainScreen] bounds].size.width), 0)))
        newPoint = CGPointMake(0, 0);
    else
        newPoint = CGPointMake(-1 * ((1536 * ratio) - [[UIScreen mainScreen] bounds].size.width), 0);
        
    floatingBackground.contents = (id)[[UIImage imageNamed:[NSString stringWithFormat:@"%i.jpg", image]] CGImage];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [floatingBackground valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:newPoint];
    animation.duration = 20.0;
    animation.delegate = self;
    
    floatingBackground.position = newPoint;
    
    [floatingBackground addAnimation:animation forKey:@"position"];
}

#pragma mark - Login logic

- (IBAction)logIn:(id)sender {
    if ([[username text] isEqualToString:@""] || [[password text] isEqualToString:@""]) {
        UIAlertView *needLoginInfoAlert = [[UIAlertView alloc] initWithTitle:@"Could not log in" message:@"Please enter your GauchoSpace username and password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [needLoginInfoAlert show];
        [needLoginInfoAlert release];
        return;
    }
    
    //Save the username and password to autofill later
    [keychain setObject:[username text] forKey:(id)kSecAttrAccount];
    [keychain setObject:[password text] forKey:(id)kSecValueData];
    
    //Start the login request
    GMSourceFetcher *sourceFetcher = [[GMSourceFetcher alloc] init];
    [sourceFetcher loginWithUsername:[username text] password:[password text] delegate:self];
    [loginButton setEnabled:NO];
    
    navBar.layer.zPosition = navBar.layer.zPosition + 1;
    
    //Present the loading view
    loadingView = [[GMLoadingView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 17, 280, 27)];
    loadingView.layer.zPosition = navBar.layer.zPosition - 1;
    [self.view addSubview:loadingView];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, loadingView.layer.position.y + 25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
}

- (void)sourceFetchDidFailWithError:(NSError *)error {
    UIAlertView *loginFailedAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:[NSString stringWithFormat:@"Logging in failed with the following error: %@", [error description]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [loginFailedAlert show];
    [loginFailedAlert release];
    [loginButton setEnabled:YES];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, loadingView.layer.position.y - 25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] addAnimation:animation forKey:@"position"];
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:loadingView.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(loadingView.layer.position.x, loadingView.layer.position.y - 25)];
    animation.duration = 0.25;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [[loadingView layer] removeAllAnimations];
    [[loadingView layer] addAnimation:animation forKey:@"position"];
    
    if ([source rangeOfString:@"You are logged in as"].location != NSNotFound) {
        
        //Snag our session key
        source = [source substringFromIndex:[source rangeOfString:@"sesskey="].location + 8];
        NSString *sessionKey = [source substringToIndex:[source rangeOfString:@"&"].location];
        [[NSUserDefaults standardUserDefaults] setObject:sessionKey forKey:@"sessionkey"];
        
        [floatingBackground removeAllAnimations];
        GMDataSource *dataSource = [GMDataSource sharedDataSource];
        //Set the username and password on the data source so it can cache appropriately
        dataSource.username = username.text;
        dataSource.password = password.text;
        
        //Try to load from the cache
        //[dataSource restoreData];
        
        //Parse and add the list of courses
        GMCourseParser *parser = [[GMCourseParser alloc] init];
        NSArray *courses = [[parser coursesFromSource:source] retain];
        
        for (GMCourse *course in courses) {
            [dataSource addCourse:course];
        }
        
        [courses release];
        [parser release];
        
        //Clear out the login view and display the list of courses
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        UIAlertView *loginFailedAlert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:[NSString stringWithFormat:@"GauchoMobile was unable to log in. Check your username and password and try again."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [loginFailedAlert show];
        [loginFailedAlert release];
        [loginButton setEnabled:YES];
    }
}

#pragma mark - Keyboard behavior

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:username]) {
        [password becomeFirstResponder];
    }
    else if ([textField isEqual:password]) {
        [self logIn:nil];
    }
    
    return YES;
}

- (void)dismissKeyboard {
    [username resignFirstResponder];
    [password resignFirstResponder];
}

@end
