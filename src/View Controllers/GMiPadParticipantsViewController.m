//
//  GMiPadParticipantsViewController.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 4/3/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMiPadParticipantsViewController.h"

@implementation GMiPadParticipantsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    [super sourceFetchSucceededWithPageSource:source];
    [((GMGridView *)self.view) reloadData];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [super requestFinished:request];
    [((GMGridView *)self.view) reloadData];
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    NSMutableDictionary *participants = [[[GMDataSource sharedDataSource] currentCourse].participants copy];
    NSInteger total = 0;
    for (NSString *key in [participants allKeys]) {
        total += [[participants objectForKey:key] count];
    }
    
    [participants release];
    
    return total;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        return CGSizeMake(120, 135);
    } else {
        return CGSizeMake(120, 135);
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index {
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    GMParticipant *participant = [self participantAtIndex:index];
    
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *photo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, size.width - 20, size.width - 20)];
    photo.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    photo.layer.shadowOffset = CGSizeMake(0, 0);
    photo.layer.shadowOpacity = 0.5;
    photo.layer.shadowRadius = 4;
    photo.layer.shouldRasterize = YES;
    if([pictures objectForKey:[participant.imageURL absoluteString]] != nil) {
        photo.image = [pictures objectForKey:[participant.imageURL absoluteString]];
    } else {
        photo.image = [UIImage imageNamed:@"defaulticon.png"];
    }
    
    [cell.contentView addSubview:photo];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, size.height - 25, size.width - 20, 15)];
    label.text = participant.name;
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:12];
    [cell.contentView addSubview:label];
    
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return NO;
}

- (GMParticipant *)participantAtIndex:(NSInteger)index {
    NSMutableDictionary *participants = [[GMDataSource sharedDataSource] currentCourse].participants;
    NSInteger currentIndex = 0;
    for (NSString *key in [participants allKeys]) {
        for (int i = 0; i < [[participants objectForKey:key] count]; i++) {
            if (currentIndex == index) {
                return [[participants objectForKey:key] objectAtIndex:i];
            }
            currentIndex++;
        }
    }
    
    return nil;
}

@end
