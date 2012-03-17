//
//  GMiPadAssignmentsViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/16/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMiPadAssignmentsViewController.h"

@interface GMiPadAssignmentsViewController ()

@end

@implementation GMiPadAssignmentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loadAssignments) 
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadAssignments {
    [self loadAssignmentsWithLoadingView:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"GMCurrentCourseChangedNotification" 
                                                  object:nil];
    [super dealloc];
}

@end
