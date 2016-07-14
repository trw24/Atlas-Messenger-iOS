//
//  LSQRCodeScannerController.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 2/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "ATLMQRScannerController.h"
#import "ATLMOverlayView.h"
#import "ATLMUtilities.h"
#import "ATLMErrors.h"

#import <AVFoundation/AVFoundation.h>
#import <ClusterPrePermissions/ClusterPrePermissions.h>

@interface ATLMQRScannerController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) NSString *applicationID;

@end

@implementation ATLMQRScannerController

NSString *const ATLMDidReceiveLayerAppID = @"ATLMDidRecieveLayerAppID";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isReading = NO;
    
    [self askForCameraPermissions];
}

- (void)setupOverlay
{
    ATLMOverlayView *overlayView = [[ATLMOverlayView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:overlayView];
}

- (void)askForCameraPermissions
{
    [[ClusterPrePermissions sharedPermissions] showCameraPermissionsWithTitle:@"Access Your Camera?"
                                                                      message:@"Atlas Messenger needs to access your camera to scan the QR Code.  You cannot proceed without giving permission."
                                                              denyButtonTitle:@"Not Now"
                                                             grantButtonTitle:@"OK"
                                                            completionHandler:^(BOOL hasPermission, ClusterDialogResult userDialogResult, ClusterDialogResult systemDialogResult) {
                                                                if (hasPermission) {
                                                                    [self setupCaptureSession];
                                                                    [self setupOverlay];
                                                                    [self toggleQRCapture];
                                                                } else if (userDialogResult == ClusterDialogResultDenied) {
                                                                    [self askForCameraPermissions];
                                                                }
    }];
}

- (void)setupCaptureSession
{
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSError *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMDeviceTypeNotSupported userInfo:@{NSLocalizedDescriptionKey : @"Cannot scan QR Codes from the simulator"}];
            ATLMAlertWithError(error);
        return;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("appID-capture-queue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:self.videoPreviewLayer];
}

- (void)toggleQRCapture
{
    if (!_isReading) {
        [self.captureSession startRunning];
    } else {
        [self.captureSession stopRunning];
    }
    _isReading = !_isReading;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            if (!self.applicationID) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self toggleQRCapture];
                    self.applicationID = metadataObj.stringValue;
                    [self notifyDelegateOfAppID:self.applicationID];
                });
            }
            _isReading = NO;
        }
    }
}

- (void)notifyDelegateOfAppID:(NSString *)appID
{
    NSURL *applicationID = [NSURL URLWithString:appID];
    if (applicationID) {
        if ([self.delegate respondsToSelector:@selector(scannerController:didScanLayerAppID:)]) {
            [self.delegate scannerController:self didScanLayerAppID:applicationID];
        }
    } else {
        NSError *error = [[NSError alloc] initWithDomain:ATLMErrorDomain code:ATLMInvalidAppIDString userInfo:@{ NSLocalizedDescriptionKey: @"There was an error scanning the QR code. Please try again." }];
        if ([self.delegate respondsToSelector:@selector(scannerController:didFailWithError:)]) {
            [self.delegate scannerController:self didFailWithError:error];
        }
    }
}

@end
