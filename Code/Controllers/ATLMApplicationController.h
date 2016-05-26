//
//  ATLMApplicationController.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
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


#import <Foundation/Foundation.h>
#import "ATLMAuthenticationProvider.h"
#import "ATLMLayerClient.h"

@class ATLMSplitViewController;

extern NSString * _Nonnull const ATLMLayerApplicationID;
extern NSString * _Nonnull const ATLMConversationMetadataDidChangeNotification;
extern NSString * _Nonnull const ATLMConversationParticipantsDidChangeNotification;
extern NSString * _Nonnull const ATLMConversationDeletedNotification;

/**
 @abstract The `ATLMApplicationController` manages global resources needed by multiple view controller classes in the Atlas Messenger App.
 It also implement the `LYRClientDelegate` protocol. Only one inst ance should be instantiated and it should be passed to 
 controllers that require it.
 */
@interface ATLMApplicationController : NSObject <LYRClientDelegate>

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

/**
 @abstract Initializes the `ATLMApplicationController` instance with the supplied provider. 
 @param provider An object conforming to the `ATLMAuthenticating protocol. 
 */
+ (nonnull instancetype)applicationControllerWithAuthenticationProvider:(nonnull id<ATLMAuthenticating>)authenticationProvider;

/**
 @abstract Authenticates the application by performing the Layer authentication handshake.
 @param credentials An `NSDictionary` containing authetication credentials. 
 @param completions A block to be called upon completion of the operation.
 */
- (void)authenticateWithCredentials:(nonnull NSDictionary *)credentials completion:(nonnull void (^)(LYRSession * _Nonnull session, NSError * _Nonnull error))completion;

/**
 @abstract Updates the controller with a `LYRClient` instance.
 @param client The `LYRClient` instancce.
 */
- (void)updateWithLayerClient:(nonnull LYRClient *)client;

///--------------------------------
/// @name Global Resources
///--------------------------------

/**
 @abstract The `LSAPIManager` object for the application.
 */
@property (nonnull, nonatomic, readonly) id <ATLMAuthenticating> authenticationProvider;

/**
 @abstract The `LYRClient` object for the application.
 */
@property (nullable, nonatomic, readonly) LYRClient *layerClient;

/**
 @abstract The `ATLMSplitViewController` controller which is the application's root controller.
 */
@property (nullable, weak, nonatomic) ATLMSplitViewController *splitViewController;

@end
