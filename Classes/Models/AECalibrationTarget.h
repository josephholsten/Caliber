//
//  AECalibrationTarget.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/18/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AECalibrationTarget

- (void)setResolution:(CGSize)size;
- (void)calibrateWithImages:(NSArray*)images intoModifiedImages:(NSMutableArray*)modified;

@end
