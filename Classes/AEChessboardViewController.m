//
//  ChessboardViewController.m
//  Chessboard
//
//  Created by Nathan Matthews on 9/11/10.
//  Copyright Astral Elvis LLC 2010. All rights reserved.
//

#import "AEChessboardViewController.h"
#import "Utilities.h"

@implementation AEChessboardViewController

- (IBAction)getImageFromCamera:(id) sender {
	pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	NSArray* mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	pickerController.mediaTypes = mediaTypes;
    [self presentModalViewController:pickerController animated:YES];
}


- (IBAction)getImageFromPhotoAlbum:(id) sender {
	pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentModalViewController:pickerController animated:YES];
}


- (IBAction)chessboardDetect:(id) sender {
    UIImage* processedImage = NULL;
    int i = 0;
    for (UIImage* image in images) {
        processedImage = [Utilities opencvChessboardDetect:imageView.image forCorners:[self cornersForBoard:(i++)]];
    }
    imageView.image = processedImage;
    [self opencvCalibrateCamera];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissModalViewControllerAnimated:YES];
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	image = [Utilities scaleAndRotateImage:image];
    imageView.image = image;
    [images addObject:image];
    
    if ([images count] >= 3)
        calibrateButton.enabled = YES;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    numCorners = 7 * 7;

    images = [[NSMutableArray alloc] init];
    chessboardCorners = malloc(sizeof(CvPoint2D32f) * numCorners * 100); // TODO: 100 is just a hack...
    calibration = [[AECameraCalibration alloc] init];
    
	pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    
    calibrateButton.enabled = NO;
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		cameraButton.enabled = YES; 
	} else {
		cameraButton.enabled = NO;
	}
}
     
- (CvPoint2D32f*) cornersForBoard:(int)boardIndex {
    return &chessboardCorners[boardIndex * numCorners];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [pickerController release];
    [imageView release];
    [images release];
    [calibration release];
    free(chessboardCorners);
    [super dealloc];
}


- (void) opencvCalibrateCamera {
    
    int boardWidth = 7;
    int numImages = [images count];
    int totalCorners = numImages * numCorners;
    UIImage* firstImages = [images objectAtIndex:0];
    CGSize imageSize = [firstImages size];
    CvPoint2D32f* corners = chessboardCorners;
    
    // Allocate Sotrage
    CvMat* image_points         = cvCreateMat(totalCorners, 2, CV_32FC1);
    CvMat* object_points		= cvCreateMat(totalCorners, 3, CV_32FC1);
    CvMat* point_counts			= cvCreateMat(numImages, 1, CV_32SC1);
    CvMat* intrinsic_matrix		= cvCreateMat(3, 3, CV_32FC1);
    CvMat* distortion_coeffs	= cvCreateMat(5, 1, CV_32FC1);
    
    // If we got a good board, add it to our data
    for (int i = 0; i < numImages; i++) {
        for (int j = i * numCorners, k = 0; k < numCorners; j++, k++) {
            CV_MAT_ELEM(*image_points, float, j, 0) = corners[j].x;
            CV_MAT_ELEM(*image_points, float, j, 1) = corners[j].y;
            CV_MAT_ELEM(*object_points, float, j, 0) = k / boardWidth;
            CV_MAT_ELEM(*object_points, float, j, 1) = k % boardWidth;
            CV_MAT_ELEM(*object_points, float, j, 2) = 0.0f;            
        }
        CV_MAT_ELEM(*point_counts, int, i, 0) = numCorners;
    }
    
    CV_MAT_ELEM(*intrinsic_matrix, float, 0, 0) = 1.0;
    CV_MAT_ELEM(*intrinsic_matrix, float, 1, 1) = 1.0;
    
    // Calibrate the camera
    cvCalibrateCamera2(object_points, image_points, point_counts, cvSize(imageSize.width, imageSize.height),
                       intrinsic_matrix, distortion_coeffs, NULL, NULL, CV_CALIB_FIX_PRINCIPAL_POINT ); 
    
    // Copy results to calibration object
    calibration->focalX = CV_MAT_ELEM(*intrinsic_matrix, float, 0, 0);
    calibration->focalY = CV_MAT_ELEM(*intrinsic_matrix, float, 1, 1);
    calibration->centerX = CV_MAT_ELEM(*intrinsic_matrix, float, 0, 2);
    calibration->centerY = CV_MAT_ELEM(*intrinsic_matrix, float, 1, 2);
    
    for (int i = 0; i < 5; i++)
        calibration->distorion[i] = CV_MAT_ELEM(*distortion_coeffs, float, i, 0);
    
    // Release CV memory
    cvReleaseMat(&image_points);
    cvReleaseMat(&object_points);
    cvReleaseMat(&point_counts);
    cvReleaseMat(&intrinsic_matrix);
    cvReleaseMat(&distortion_coeffs);
}

@end
