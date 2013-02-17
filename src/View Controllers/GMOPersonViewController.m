//
//  GMOPersonViewController.m
//  GauchoMobile
//
//  GMOPersonViewController is a subclass of ABPersonViewController that adds a Done button
//  to allow it to be dismissed when presented modally on the iPad.
//

#import "GMOPersonViewController.h"

@implementation GMOPersonViewController

- (id)init {
    if (self = [super init]) {
        /* Register for notifications when we resume from the background – the underlying subclass
           appears to clear the bar button item, so make sure it gets put back so we don't get stuck
           with an undismissable view */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addDoneButton)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // The Edit button is in the same place as the Done button we're adding, so disallow editing
    self.allowsEditing = NO;
    [self addDoneButton];
}

- (void)addDoneButton {
    /* Only add the done button on the iPad, since otherwise this view controller will be pushed onto
       the navigation stack, and thus be dismissable with the normal back arrow button */
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(dismissModalViewControllerAnimated:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [super dealloc];
}

@end
