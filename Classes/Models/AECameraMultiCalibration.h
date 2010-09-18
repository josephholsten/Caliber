//
//  AECameraMultiCalibration.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/18/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AECalibrationTarget.h"

@class AECameraCalibration;

@interface AECameraMultiCalibration : NSObject <AECalibrationTarget> {
    CGSize resolution;
@private
    AECameraCalibration* noneFixed;
    AECameraCalibration* aspectFixed;
    AECameraCalibration* centerFixed;
    AECameraCalibration* bothFixed;
}

@end
