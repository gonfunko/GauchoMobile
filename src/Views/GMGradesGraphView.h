//
//  GMGradesGraphView.h
//  GauchoMobile
//
//  Created by Aaron Dodson on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMDataSource.h"
#import "GMGrade.h"

@interface GMGradesGraphView : UIView {
    CATextLayer *currentGrade;
    CATextLayer *average;
    NSMutableArray *barLayers;
    int courseAverage;
}

//Creates and displays the bars in the graph
- (void)loadBars;

@end
