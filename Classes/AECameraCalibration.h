//
//  AECameraCalibration.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/14/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AECameraCalibration : NSObject {

    @public
    
    float focalX;
    float focalY;
    float centerX;
    float centerY;
    
    float distorion[5];
}

@end
