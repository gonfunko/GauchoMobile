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
    
    [collectionView registerClass:[GMParticipantCollectionViewCell class] forCellWithReuseIdentifier:@"participantCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.visible = YES;
    
    GMCourse *currentCourse = [[GMDataSource sharedDataSource] currentCourse];
    if ([[currentCourse participantsArray] count] == 0) {
        [self loadParticipants];
    } else {
        [collectionView reloadData];
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
        [self loadParticipants];
    }
}

- (void)sourceFetchSucceededWithPageSource:(NSString *)source {
    [super sourceFetchSucceededWithPageSource:source];
    [collectionView reloadData];
}

- (void)gotImageData:(NSDictionary *)imgData {
    [super gotImageData:imgData];
    [collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    return [[[GMDataSource sharedDataSource] currentCourse].participantsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GMParticipantCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"participantCell" forIndexPath:indexPath];
    GMParticipant *participant = [[[GMDataSource sharedDataSource] currentCourse].participantsArray objectAtIndex:indexPath.row];
    
    cell.label.text = participant.name;
    if([pictures objectForKey:[participant.imageURL absoluteString]] != nil) {
        cell.imageView.image = [pictures objectForKey:[participant.imageURL absoluteString]];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"defaulticon.png"];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GMParticipant *touchedPerson = [[[GMDataSource sharedDataSource] currentCourse].participantsArray objectAtIndex:indexPath.row];
    [self displayAddressBookEntryForParticipant:touchedPerson];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GMCurrentCourseChangedNotification" object:nil];
    [super dealloc];
}

@end
