//
//  ChessboardAppDelegate.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/11/10.
//  Copyright Astral Elvis LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AEFrameCaptureViewController;
@class AECameraMultiCalibration;

@interface AEChessboardAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow* window;
    AEFrameCaptureViewController* viewController;
@private
    AECameraMultiCalibration* calibration;
}

@property (nonatomic, retain) IBOutlet UIWindow* window;
@property (nonatomic, retain) IBOutlet AEFrameCaptureViewController* viewController;

@end