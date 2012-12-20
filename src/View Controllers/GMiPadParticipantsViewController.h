//
//  GMiPadParticipantsViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 4/3/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "ParticipantsViewController.h"
#import "GMParticipantCollectionViewCell.h"

@interface GMiPadParticipantsViewController : ParticipantsViewController <UICollectionViewDataSource, UICollectionViewDelegate> {
    IBOutlet UICollectionView *collectionView;
    
    BOOL visible;
}

@property (assign) BOOL visible;

@end
