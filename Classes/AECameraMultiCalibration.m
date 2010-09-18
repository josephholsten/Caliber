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
- (void)findChessboardsInImages:(NSArray*)images
                    intoCorners:(CvPoint2D32f*)corners
             intoModifiedImages:(NSMutableArray*)modified;
@end


@implementation AECameraMultiCalibration

- (id)init
{
    if (![super init])
        return nil;
    
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

- (void)calibrateWithImages:(NSArray *)images intoModifiedImages:(NSMutableArray*)modified
{
    int numImages = [images count];
    int numCorners = 7 * 7;
    CvPoint2D32f corners[numCorners * numImages];
    CvPoint2D32f* cornersPtr = &corners[0];
    
    [self findChessboardsInImages:images intoCorners:cornersPtr intoModifiedImages:modified];
    
    [self forEachCalibration:^(AECameraCalibration* calibration) {
        [calibration calibrate:numImages
                   withCorners:cornersPtr
                 andResolution:resolution];
    }];
}

- (void)findChessboardsInImages:(NSArray*)images
                    intoCorners:(CvPoint2D32f*)corners
             intoModifiedImages:(NSMutableArray*)modified
{
    int numImages = [images count];
    int numCorners = 7 * 7;
    CvPoint2D32f* imageCorners = corners;
    
    for (int i = 0; i < numImages; i++, imageCorners += numCorners) {
        UIImage* oldImage = [images objectAtIndex:i];
        UIImage* newImage = [Utilities opencvChessboardDetect:oldImage forCorners:imageCorners];
        [modified addObject:newImage];
    }
}

- (void)dealloc
{
    [self forEachCalibration:^(AECameraCalibration* calibration) {
        [calibration release];
    }];
    [super dealloc];
}

@end
