//
//  ChessboardViewController.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/11/10.
//  Copyright Astral Elvis LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AECalibrationTarget.h"

@interface AEChessboardViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

    id<AECalibrationTarget> calibrationTarget;

@private
    
	IBOutlet UIImageView *imageView;
    IBOutlet UIBarButtonItem* cameraButton;
    IBOutlet UIBarButtonItem* calibrateButton;
	UIImagePickerController* pickerController;
    NSMutableArray* images;
}

@property (nonatomic, retain) id<AECalibrationTarget> calibrationTarget;

- (IBAction) getImageFromCamera      : (id) sender;
- (IBAction) getImageFromPhotoAlbum  : (id) sender;
- (IBAction) chessboardDetect        : (id) sender;

@end
