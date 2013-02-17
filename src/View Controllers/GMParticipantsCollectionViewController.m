//
//  GMParticipantsCollectionViewController.m
//  GauchoMobile
//
//  GMParticipantsCollectionViewController is responsible for providing data, and configuring cells
//  for the grid of participants in a course
//

#import "GMParticipantsCollectionViewController.h"

@interface GMParticipantsCollectionViewController () {
    // We keep a reference to our parent view controller to avoid having to cast self.parentViewController
    GMOParticipantsViewController *parent;
}

@end

@implementation GMParticipantsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    parent = (GMOParticipantsViewController *)self.parentViewController;

    // Register the class containing our collection view cells with the collection view
    [self.collectionView registerClass:[GMParticipantCollectionViewCell class] forCellWithReuseIdentifier:@"participantCell"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)loadingStarted {}

/* Required by the GMParticipantsChildViewController protocol – we have no loading UI to hide,
 so do nothing */
- (void)loadingFinished {}

/* Part of the GMParticipantsChildViewController protocol – just pass the reloadData message on to
   the collection view */
- (void)reloadData {
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    return [[GMDataSource sharedDataSource].currentCourse.participantsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GMParticipantCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"participantCell" forIndexPath:indexPath];
    GMParticipant *participant = [[GMDataSource sharedDataSource].currentCourse.participantsArray objectAtIndex:indexPath.row];
    
    cell.label.text = participant.name;
    /* If the pictures array of our parent VC has an entry for this participant's image URL, use that
       photo; otherwise, use the default smiley one */
    if ([parent.pictures objectForKey:[participant.imageURL absoluteString]] != nil) {
        cell.imageView.image = [parent.pictures objectForKey:[participant.imageURL absoluteString]];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"defaulticon.png"];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GMParticipant *touchedPerson = [[GMDataSource sharedDataSource].currentCourse.participantsArray objectAtIndex:indexPath.row];
    [parent displayAddressBookEntryForParticipant:touchedPerson];
}

@end
