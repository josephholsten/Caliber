//
//  ChessboardAppDelegate.m
//  Chessboard
//
//  Created by Nathan Matthews on 9/11/10.
//  Copyright Astral Elvis LLC 2010. All rights reserved.
//

#import "AEChessboardAppDelegate.h"
#import "AEChessboardViewController.h"
#import "AECameraMultiCalibration.h"

@implementation AEChessboardAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    calibration = [[AECameraMultiCalibration alloc] init];
    viewController.calibrationTarget = calibration;
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [calibration release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end
