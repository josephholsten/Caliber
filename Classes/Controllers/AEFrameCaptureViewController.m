    //
//  AEFrameCaptureViewController.m
//  Chessboard
//
//  Created by Nathan Matthews on 9/19/10.
//  Copyright 2010 Astral Elvis LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AEFrameCaptureViewController.h"
#import "Utilities.h"
#import "../opencv/cv.h"

@implementation AEFrameCaptureViewController

@synthesize calibrationTarget;

- (void)initCapture
{
    NSLog(@"Initializing capture");
    
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    collectFrames = YES;
    NSError* error = nil;
    
    if ([device lockForConfiguration:&error]) {
    //    device.focusMode = AVCaptureFocusModeLocked;
        [device unlockForConfiguration];
    } else {
        NSLog(@"Couldn't configure device: %s", [error localizedDescription]);
    }
    
	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	captureOutput.alwaysDiscardsLateVideoFrames = YES; 
	//captureOutput.minFrameDuration = CMTimeMake(1, 10);
	
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
	
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey; 
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
	[captureOutput setVideoSettings:videoSettings]; 
	
    NSLog(@"Configured capture parameters");
    
    captureSession = [[AVCaptureSession alloc] init];
	[captureSession addInput:captureInput];
	[captureSession addOutput:captureOutput];
    
    // TODO: release memory for device, captureInput, captureOutput, videoSettings?
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Calling viewDidLoad");
    [self initCapture];
	previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
	previewLayer.frame = self.view.bounds;
	previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer addSublayer:previewLayer];
    NSLog(@"Added preview layer");    
    [captureSession startRunning];
    NSLog(@"Started capture session");
}


- (void)viewDidUnload {
    [previewLayer release];
    [captureSession stopRunning];
    [captureSession release];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{ 
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    if (collectFrames) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
        CVPixelBufferLockBaseAddress(imageBuffer,0); 
        
        // Get information about image
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
        size_t width = CVPixelBufferGetWidth(imageBuffer); 
        size_t height = CVPixelBufferGetHeight(imageBuffer);  
        
        // Create the an image using the buffer memory
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
        CGContextRef avContext = CGBitmapContextCreate(baseAddress, width, height, 
                                                       8, bytesPerRow, 
                                                       colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef avImage = CGBitmapContextCreateImage(avContext); 	
        
        // Create an image by drawing into opencv memory
        IplImage* cvImage = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 4);
        CGContextRef cvContext = CGBitmapContextCreate(cvImage->imageData, width, height,
                                                       cvImage->depth, cvImage->widthStep, 
                                                       colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault);
        CGContextDrawImage(cvContext, CGRectMake(0, 0, width, height), avImage);

        // Drop some AV stuff we don't need now
        CGContextRelease(avContext);
        CGContextRelease(cvContext);
        CGColorSpaceRelease(colorSpace);
        CGImageRelease(avImage);
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        // Convert the IplImage to BGR
        IplImage* bgr = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 3);
        cvCvtColor(cvImage, bgr, CV_RGBA2BGR);
        cvReleaseImage(&cvImage);
        
        // Shrink image
        IplImage* small = cvCreateImage(cvSize(width/2, height/2), IPL_DEPTH_8U, 3);
        cvResize(bgr, small, CV_INTER_LINEAR);
        cvReleaseImage(&bgr);
        
        // Detect a chessboard
        CvPoint2D32f corners[BOARD_SIZE * BOARD_SIZE];
        if ([Utilities opencvChessboardDetect:small forCorners:corners]) {
            [self.calibrationTarget addCorners:&corners[0]];
            NSLog(@"Found chessboard; %f%% done", (100.0 * [self.calibrationTarget progress]));
            // TODO: advance progress bar
        }
        
        if ([self.calibrationTarget hasEnoughCorners]) {
            [self.calibrationTarget setResolution:CGSizeMake(small->width, small->height)];
            [self.calibrationTarget calibrate];
            collectFrames = NO;
        }
        
        cvReleaseImage(&small);
    }
    [pool drain];
} 


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [previewLayer release];
    [captureSession release];
    [super dealloc];
}


@end
