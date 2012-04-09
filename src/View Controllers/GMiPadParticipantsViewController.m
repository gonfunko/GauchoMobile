//
//  GMiPadParticipantsViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 4/3/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMiPadParticipantsViewController.h"

@implementation GMiPadParticipantsViewController

@synthesize visible;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadParticipants)
                                                 name:@"GMCurrentCourseChangedNotification" 
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.visible = YES;
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    if ([[currentCourse participantsArray] count] == 0) {
        [self loadParticipantsWithLoadingView:YES];
    } else {
        [((GMGridView *)self.view) reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.visible = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadParticipants {
    if (self.visible) {
        [self loadParticipantsWithLoadingView:YES];
    }
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    [super sourceFetchSucceededWithPageSource:source];
    [((GMGridView *)self.view) reloadData];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [super requestFinished:request];
    [((GMGridView *)self.view) reloadData];
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [[[GMDataSource sharedDataSource] currentCourse].participantsArray count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGSizeMake(120, 140);
    } else {
        return CGSizeMake(130, 150);
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    GMParticipant *participant = [[[GMDataSource sharedDataSource] currentCourse].participantsArray objectAtIndex:index];
    
    if (!cell) {
        cell = [[[GMGridViewCell alloc] init] autorelease];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        cell.contentView = view;
        [view release];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *photo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, size.width - 20, size.width - 20)];
    photo.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    photo.layer.shadowOffset = CGSizeMake(0, 0);
    photo.layer.shadowOpacity = 0.5;
    photo.layer.shadowRadius = 4;
    photo.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    photo.layer.shouldRasterize = YES;
    if([pictures objectForKey:[participant.imageURL absoluteString]] != nil) {
        photo.image = [pictures objectForKey:[participant.imageURL absoluteString]];
    } else {
        photo.image = [UIImage imageNamed:@"defaulticon.png"];
    }
    
    [cell.contentView addSubview:photo];
    [photo release];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, size.height - 30, size.width - 20, 30)];
    label.text = participant.name;
    label.textAlignment = UITextAlignmentCenter;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:84/255.0 green:95/255.0 blue:105/255.0 alpha:1.0];
    label.font = [UIFont boldSystemFontOfSize:12];
    [cell.contentView addSubview:label];
    [label release];
    
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index {
    return NO;
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    GMParticipant *touchedPerson = [[[GMDataSource sharedDataSource] currentCourse].participantsArray objectAtIndex:position];
    [self displayAddressBookEntryForParticipant:touchedPerson];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GMCurrentCourseChangedNotification" object:nil];
    [super dealloc];
}

@end
