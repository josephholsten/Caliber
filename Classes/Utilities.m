//
//  Utilities.m
//  FaceDetect
//
//  Created by Alasdair Allan on 15/12/2009.
//  Copyright 2009 University of Exeter. All rights reserved.
//

#import "Utilities.h"
#import "opencv/cv.h"

@implementation Utilities

#pragma mark Utility Methods

+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    NSLog(@"UIImage (%d, %d)", [image size].width, [image size].height);
	CGImageRef imageRef = image.CGImage;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
	CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
	
	return ret;
}

+ (UIImage *)UIImageFromIplImage:(IplImage *)image {
	NSLog(@"IplImage (%d, %d) %d bits by %d channels, %d bytes/row %s", image->width, image->height, image->depth, image->nChannels, image->widthStep, image->channelSeq);
	
    IplImage *iplimage = cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 3);
    cvCvtColor(image, iplimage, CV_BGR2RGB);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	NSData *data = [NSData dataWithBytes:iplimage->imageData length:iplimage->imageSize];
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(iplimage->width, iplimage->height,
										iplimage->depth, iplimage->depth * iplimage->nChannels, iplimage->widthStep,
										colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
										provider, NULL, false, kCGRenderingIntentDefault);
	UIImage *ret = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
    cvReleaseImage(&iplimage);
	return ret;
}


+ (UIImage *)scaleAndRotateImage:(UIImage *)image {
	static int kMaxResolution = 640;
	
	CGImageRef imgRef = image.CGImage;
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		} else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
		case UIImageOrientationUp:
			transform = CGAffineTransformIdentity;
			break;
		case UIImageOrientationUpMirrored:
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
		case UIImageOrientationDown:
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
		case UIImageOrientationLeftMirrored:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
		case UIImageOrientationLeft:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
		case UIImageOrientationRightMirrored:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		case UIImageOrientationRight:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return returnImage;
}

+ (BOOL) opencvChessboardDetect:(IplImage*)image forCorners:(CvPoint2D32f*)corners {

    cvSetErrMode(CV_ErrModeParent);

    // set up the board-finding parameters
    int numSquares = 7;
    CvSize boardSize = cvSize(numSquares, numSquares);
    int numCorners;
    
    // detect chessboard corners
    int found = cvFindChessboardCorners(image, boardSize, corners, &numCorners, 0);
    if (found > 0) {
        // should this use IPL_DEPTH_8U instead of 8? 
        IplImage *gray = cvCreateImage(cvGetSize(image), 8, 1);

        cvCvtColor(image, gray, CV_BGR2GRAY);
        cvFindCornerSubPix(gray, corners, numCorners, cvSize(11, 11), cvSize(-1, -1), 
                           cvTermCriteria( CV_TERMCRIT_EPS+CV_TERMCRIT_ITER, 30, 0.1));

        cvReleaseImage(&gray);
        return YES;
    }
    
    return NO;
}

+ (BOOL) isChessboardLikelyInImage:(IplImage*)image
{
    cvSetErrMode(CV_ErrModeParent);

    int numSquares = 7;
    int numCorners;
    CvSize boardSize = cvSize(numSquares, numSquares);
    CvPoint2D32f corners[numSquares * numSquares];
    
    int found = cvFindChessboardCorners(image, boardSize, corners, &numCorners, CV_CALIB_CB_FAST_CHECK);
    //int found = cvCheckChessboard(image, boardSize);
    return (found > 0);
}

@end
