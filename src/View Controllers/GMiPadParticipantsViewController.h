//
//  GMiPadParticipantsViewController.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 4/3/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "ParticipantsViewController.h"
#import "GMGridView.h"

@interface GMiPadParticipantsViewController : ParticipantsViewController <GMGridViewDataSource, GMGridViewActionDelegate> {
    BOOL visible;
}

@property (assign) BOOL visible;

@end
