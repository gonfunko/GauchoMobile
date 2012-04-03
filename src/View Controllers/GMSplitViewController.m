//
//  GMSplitViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 4/3/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMSplitViewController.h"

@implementation GMSplitViewController

@synthesize barButtonItem;

- (void)viewWillLayoutSubviews
{
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        ((UINavigationController *)[self.viewControllers objectAtIndex:1]).topViewController.navigationItem.leftBarButtonItem = self.barButtonItem;
    } else {
        ((UINavigationController *)[self.viewControllers objectAtIndex:1]).topViewController.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)dealloc {
    self.barButtonItem = nil;
    [super dealloc];
}

@end
