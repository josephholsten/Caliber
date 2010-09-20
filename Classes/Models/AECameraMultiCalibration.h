//
//  AECameraMultiCalibration.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/18/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AECalibrationTarget.h"
#import "Constants.h"

@class AECameraCalibration;

@interface AECameraMultiCalibration : NSObject <AECalibrationTarget> {
    CGSize resolution;
    int numImages;
@private
    AECameraCalibration* noneFixed;
    AECameraCalibration* aspectFixed;
    AECameraCalibration* centerFixed;
    AECameraCalibration* bothFixed;
    CvPoint2D32f corners[BOARD_SIZE * BOARD_SIZE * MAX_CALIB_IMAGES];
}

@end
