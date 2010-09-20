//
//  AECameraMultiCalibration.m
//  Chessboard
//
//  Created by Nathan Matthews on 9/18/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import "AECameraMultiCalibration.h"
#import "AECameraCalibration.h"
#import "Utilities.h"

@interface AECameraMultiCalibration (PrivateMethods)
- (void)forEachCalibration:(void (^)(AECameraCalibration* calibration))block;
@end


@implementation AECameraMultiCalibration

- (id)init
{
    if (![super init])
        return nil;
    
    numImages = 0;
    noneFixed = [[AECameraCalibration alloc] initWithFlags:0];
    aspectFixed = [[AECameraCalibration alloc] initWithFlags:CV_CALIB_FIX_ASPECT_RATIO];
    centerFixed = [[AECameraCalibration alloc] initWithFlags:CV_CALIB_FIX_PRINCIPAL_POINT];
    bothFixed = [[AECameraCalibration alloc] initWithFlags:(CV_CALIB_FIX_PRINCIPAL_POINT | CV_CALIB_FIX_ASPECT_RATIO)];
    
    return self;
}

- (void)forEachCalibration:(void (^)(AECameraCalibration* calibration))block
{
    block(noneFixed);
    block(aspectFixed);
    block(centerFixed);
    block(bothFixed);
}

- (void)setResolution:(CGSize)size
{
    resolution = size;
}

- (BOOL)hasEnoughCorners
{
    return (numImages >= 15);
}

- (float)progress
{
    return ((float) numImages) / 15.0;
}

- (void)addCorners:(CvPoint2D32f*)newCorners
{
    int chunk = BOARD_SIZE * BOARD_SIZE;
    for (int i = 0, j = numImages * chunk; i < chunk; i++, j++)
        corners[j] = newCorners[i];
    numImages++;
}

- (void)calibrate
{
    CvPoint2D32f* cornersPtr = &corners[0];
    [self forEachCalibration:^(AECameraCalibration* calibration) {
        [calibration calibrate:numImages 
                   withCorners:cornersPtr 
                 andResolution:resolution];
    }];
    
    NSLog(@"None fixed:");
    [noneFixed logResults];
    NSLog(@"Aspect fixed:");
    [aspectFixed logResults];
    NSLog(@"Center fixed:");
    [centerFixed logResults];
    NSLog(@"Both fixed:");
    [bothFixed logResults];
}


- (void)dealloc
{
    [self forEachCalibration:^(AECameraCalibration* calibration) {
        [calibration release];
    }];
    [super dealloc];
}

@end
