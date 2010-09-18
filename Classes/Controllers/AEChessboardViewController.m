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

@synthesize calibrationTarget;

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
    NSLog(@"Running chessboardDetect on delegate %@", calibrationTarget);
    NSMutableArray* modified = [[NSMutableArray alloc] initWithCapacity:[images count]];
    [calibrationTarget setResolution:[[images objectAtIndex:0] size]];
    [calibrationTarget calibrateWithImages:images intoModifiedImages:modified];
    UIImage* firstModified = [modified objectAtIndex:0];
    imageView.image = firstModified;
    [modified release];
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
    
    images = [[NSMutableArray alloc] init];
    
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
     
- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [pickerController release];
    [imageView release];
    [images release];
    [(id)calibrationTarget release];
    [super dealloc];
}

@end
