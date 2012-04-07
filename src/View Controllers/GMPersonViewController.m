//
//  GMPersonViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 4/7/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMPersonViewController.h"

@implementation GMPersonViewController

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDoneButton) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:24/255.0 green:69/255.0 blue:135/255.0 alpha:1.0];
    self.allowsEditing = NO;
    [self addDoneButton];
}

- (void)addDoneButton {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [super dealloc];
}

@end
