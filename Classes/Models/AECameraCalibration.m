//
//  AECameraCalibration.m
//  Chessboard
//
//  Created by Nathan Matthews on 9/14/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import "AECameraCalibration.h"

@implementation AECameraCalibration

- (id)initWithFlags:(int)initFlags;
{
    if (![super init])
        return nil;

    flags = initFlags;
    
    return self;
}

- (void)logResults
{
    NSString* matrixRow = @"| % 8.2f  % 8.2f  % 8.2f |";
    NSLog(@"Calibration results:");
    NSLog(matrixRow, focal.x, 0.0, center.x);
    NSLog(matrixRow, 0.0, focal.y, center.y);
    NSLog(matrixRow, 0.0, 0.0, 1.0);
}

- (void)calibrate:(int)numImages
      withCorners:(CvPoint2D32f*)corners
    andResolution:(CGSize) resolution
{
    int boardWidth = 7;
    int numCorners = boardWidth * boardWidth;
    int totalCorners = numImages * numCorners;
        
    // Allocate Sotrage
    CvMat* image_points         = cvCreateMat(totalCorners, 2, CV_32FC1);
    CvMat* object_points		= cvCreateMat(totalCorners, 3, CV_32FC1);
    CvMat* point_counts			= cvCreateMat(numImages, 1, CV_32SC1);
    CvMat* intrinsic_matrix		= cvCreateMat(3, 3, CV_32FC1);
    CvMat* distortion_coeffs	= cvCreateMat(5, 1, CV_32FC1);
    
    // Insert corner data and faked 3d data into matrices
    for (int i = 0; i < numImages; i++) {
        for (int j = i * numCorners, k = 0; k < numCorners; j++, k++) {
            CV_MAT_ELEM(*image_points, float, j, 0) = corners[j].x;
            CV_MAT_ELEM(*image_points, float, j, 1) = corners[j].y;
            CV_MAT_ELEM(*object_points, float, j, 0) = k / boardWidth;
            CV_MAT_ELEM(*object_points, float, j, 1) = k % boardWidth;
            CV_MAT_ELEM(*object_points, float, j, 2) = 0.0f;            
        }
        CV_MAT_ELEM(*point_counts, int, i, 0) = numCorners;
    }
    
    CV_MAT_ELEM(*intrinsic_matrix, float, 0, 0) = 1.0;
    CV_MAT_ELEM(*intrinsic_matrix, float, 1, 1) = 1.0;
    
    // Calibrate the camera
    cvCalibrateCamera2(object_points, image_points, point_counts, cvSize(resolution.width, resolution.height),
                       intrinsic_matrix, distortion_coeffs, NULL, NULL, flags); 
    
    // Copy results to calibration object
    focal.x = CV_MAT_ELEM(*intrinsic_matrix, float, 0, 0);
    focal.y = CV_MAT_ELEM(*intrinsic_matrix, float, 1, 1);
    center.x = CV_MAT_ELEM(*intrinsic_matrix, float, 0, 2);
    center.y = CV_MAT_ELEM(*intrinsic_matrix, float, 1, 2);
    for (int i = 0; i < 5; i++)
        distorion[i] = CV_MAT_ELEM(*distortion_coeffs, float, i, 0);    
     
    // Release CV memory
    cvReleaseMat(&image_points);
    cvReleaseMat(&object_points);
    cvReleaseMat(&point_counts);
    cvReleaseMat(&intrinsic_matrix);
    cvReleaseMat(&distortion_coeffs);
}

@end
