//
//  AECameraCalibration.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/14/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AECalibrationTarget.h"
#import "../opencv/cv.h"

@interface AECameraCalibration : NSObject {
    
    CGPoint focal;
    CGPoint center;
    CGFloat distortion[5];
    
@private
    
    int flags;
}

- (id)initWithFlags:(int) flags;

- (void)calibrate:(int)numImages 
      withCorners:(CvPoint2D32f*)corners
    andResolution:(CGSize)resolution;

- (void)logResults;

@end
