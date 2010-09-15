//
//  ChessboardViewController.h
//  Chessboard
//
//  Created by Nathan Matthews on 9/11/10.
//  Copyright Astral Elvis LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "opencv/cv.h"
#import "AECameraCalibration.h"

@interface AEChessboardViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
	IBOutlet UIImageView *imageView;
    IBOutlet UIBarButtonItem* cameraButton;
    IBOutlet UIBarButtonItem* calibrateButton;
	UIImagePickerController* pickerController;
    NSMutableArray* images;
    CvPoint2D32f* chessboardCorners;
    AECameraCalibration* calibration;
    int numCorners;
}

- (IBAction) getImageFromCamera      : (id) sender;
- (IBAction) getImageFromPhotoAlbum  : (id) sender;
- (IBAction) chessboardDetect        : (id) sender;

@end

@interface AEChessboardViewController (PrivateMethods)

- (CvPoint2D32f*) cornersForBoard:(int)boardIndex;
- (void) opencvCalibrateCamera;


@end