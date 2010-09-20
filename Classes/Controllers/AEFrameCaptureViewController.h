//
//  AEFrameCaptureViewController.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/19/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AECalibrationTarget.h"

@interface AEFrameCaptureViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureVideoPreviewLayer* previewLayer;
    AVCaptureSession* captureSession;
    IBOutlet UIProgressView* progressView;
    BOOL collectFrames;
    id<AECalibrationTarget> calibrationTarget;
}

@property (nonatomic, assign) id<AECalibrationTarget> calibrationTarget;

- (void)initCapture;

@end
