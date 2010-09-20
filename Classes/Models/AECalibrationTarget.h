//
//  AECalibrationTarget.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/18/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../opencv/cv.h"


@protocol AECalibrationTarget

- (void)setResolution:(CGSize)size;
- (void)addCorners:(CvPoint2D32f*)newCorners;
- (BOOL)hasEnoughCorners;
- (void)calibrate;
- (float)progress;

@end
