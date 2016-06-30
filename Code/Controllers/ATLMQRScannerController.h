//
//  LSQRCodeScannerController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 2/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <UIKit/UIKit.h>
#import "ATLMApplicationController.h"

@class ATLMQRScannerController;

/**
 @abstract The `ATLMQRScannerControllerDelegate` notifies the receiver when
   the scanner view controller detects a Layer App ID, or in case there was
   a problem during detection.
 */
@protocol ATLMQRScannerControllerDelegate <NSObject>

/**
 @abstract Tells the receiver that the QR scanner view controller detected
   a Layer App ID.
 @param scannerController The sender that did the delegate invocation.
 @param appID The Layer appID the scanner detected.
 */
- (void)scannerController:(nonnull ATLMQRScannerController *)scannerController didReceiveAppID:(nonnull NSURL *)appID;

/**
 @abstract Tells the receiver that the QR scanner view controller hit an error.
 @param scannerController The sender that did the delegate invocation.
 @param error The `NSError` instance describing the failure.
 */
- (void)scannerController:(nonnull ATLMQRScannerController *)scannerController didFailWithError:(nonnull NSError *)error;

@end

/** 
 @abstract The `ATLMQRScannerController` presents a user interface for scanning QR codes. When a QR code is succesfully scanned, it is persisted to the `NSUserDefaults` dictionary as the value for the `ATLMLayerApplicationID` key.
 */
@interface ATLMQRScannerController : UIViewController

/**
 @abstract The receiver of the appID, once the QC code scanner recognizes it.
 */
@property (nullable, nonatomic, weak) id<ATLMQRScannerControllerDelegate> delegate;

@end
