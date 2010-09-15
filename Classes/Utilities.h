//
//  Utilities.h
//  FaceDetect
//
//  Created by Alasdair Allan on 15/12/2009.
//  Copyright 2009 University of Exeter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "opencv/cv.h"

@interface Utilities : NSObject {

}

// Utility Methods
+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromIplImage:(IplImage *)image;
+ (UIImage *)scaleAndRotateImage:(UIImage *)image;

// Chessboard detection methods
+ (UIImage *) opencvChessboardDetect:(UIImage *)originalImage forCorners:(CvPoint2D32f*)corners;

@end
