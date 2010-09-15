//
//  ChessboardAppDelegate.m
//  Chessboard
//
//  Created by Nathan Matthews on 9/11/10.
//  Copyright Astral Elvis LLC 2010. All rights reserved.
//

#import "AEChessboardAppDelegate.h"
#import "AEChessboardViewController.h"

@implementation AEChessboardAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}



- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
