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
#import <LayerKit/LYRClient.h>
#import "ATLMAuthenticationProvider.h"

extern NSString * _Nonnull const ATLMConversationMetadataDidChangeNotification;
extern NSString * _Nonnull const ATLMConversationParticipantsDidChangeNotification;
extern NSString * _Nonnull const ATLMConversationDeletedNotification;

extern NSString *_Nonnull const ATLMApplicationControllerErrorDomain;

typedef NS_ENUM(NSUInteger, ATLMApplicationControllerError) {
    ATLMApplicationControllerErrorAppIDAlreadySet                  = 1, // Layer appID already set on the application controller.
    ATLMApplicationControllerErrorFailedHandlingRemoteNotification = 2, // Underlying Layer client failed to handle the remote notification.
};

///-------------------------
/// @name Application States
///-------------------------

typedef NS_ENUM(NSUInteger, ATLMApplicationState) {
    /**
     @abstract A state where the app doesn't have a Layer appID yet.
     */
    ATLMApplicationStateAppIDNotSet             = 1,
    
    /**
     @abstract A state where the app has the appID, but no user credentials.
     */
    ATLMApplicationStateCredentialsRequired     = 2,
    
    /**
     @abstract A state where the app is fully authenticated.
     */
    ATLMApplicationStateAuthenticated           = 3
};

@class ATLMApplicationController;

/**
 @abstract The `ATLMApplicationControllerDelegate` notifies the receiver about
   the application state changes so that the receiver can navigate the UI accordingly.
 */
@protocol ATLMApplicationControllerDelegate <NSObject>

@optional

/**
 @abstract Notifies the receiver the application state has changed.
 @param applicationController The `ATLMApplicationController` instance performing the invocation.
 @param applicationState New application state.
 */
- (void)applicationController:(nonnull ATLMApplicationController *)applicationController didChangeState:(ATLMApplicationState)applicationState;

/**
 @abstract Notifies the receiver the application controller has finished handling
   the remote notification and hands all the objects associated with the remote
   notification.
 @param applicationController The `ATLMApplicationController` instance performing the invocation.
 @param conversation The `LYRConversation` instance associated with the remote notification.
 @param conversation The `LYRMessage` instance associated with the remote notification.
 */
- (void)applicationController:(nonnull ATLMApplicationController *)applicationController didFinishHandlingRemoteNotificationForConversation:(nullable LYRConversation *)conversation message:(nullable LYRMessage *)message;

/**
 @abstract Notifies the receiver that the underlying Layer Client will attempt to establish a connection.
 @param applicationController The `ATLMApplicationController` instance performing the invocation.
 @param attemptNumber The number of attempts the underlying client has attempted to make.
 @param delayInterval The amount of time until the underlying Layer Client will make the next attempt.
 @param attemptLimit The maximum number of attempts the underlying Layer Client will make.
 */
- (void)applicationController:(nonnull ATLMApplicationController *)applicationController willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit;

/**
 @abstract Notifies the receiver that the underlying Layer Client has successfully established a connection.
 @param applicationController The `ATLMApplicationController` instance performing the invocation.
 */
- (void)applicationControllerDidConnect:(nonnull ATLMApplicationController *)applicationController;

/**
 @abstract Notifies the receiver that the underlying Layer Client has disconnected.
 @param applicationController The `ATLMApplicationController` instance performing the invocation.
 */
- (void)applicationControllerDidDisconnect:(nonnull ATLMApplicationController *)applicationController;

/**
 @abstract Notifies the receiver that the underlying Layer Client has lost a connection.
 @param applicationController The `ATLMApplicationController` instance performing the invocation.
 @param error The error associated with the connection loss.
 */
- (void)applicationController:(nonnull ATLMApplicationController *)applicationController didLoseConnectionWithError:(nonnull NSError *)error;

/**
 @abstract Notifies the receiver the application controller has hit an error.
 @param applicationController The `ATLMApplicationController` instance performing the invocation.
 @param error The error instance the application controller has hit.
 */
- (void)applicationController:(nonnull ATLMApplicationController *)applicationController didFailWithError:(nonnull NSError *)error;

@end

/**
 @abstract The `ATLMApplicationController` manages global resources needed by
   multiple view controller classes in the Atlas Messenger App. It also
   implements the `LYRClientDelegate` protocol. Only one instance should be
   instantiated and it should be passed to controllers that require it.
 */
@interface ATLMApplicationController : NSObject <LYRClientDelegate>

///--------------------------------
/// @name Initializing a Controller
///--------------------------------

/**
 @abstract Creates the `ATLMApplicationController` instance with the supplied provider.
 @param provider An object conforming to the `ATLMAuthenticating protocol.
 @param layerClientOptions The Layer client's options instance, which will be passed
   to the `LYRClient` during its initialization.
 @return Returns an instance of the `ATLMApplicationController` ready for use.
 @discussion The application controller creates an instance of the `LYRClient` once the
   appID is known.
 */
+ (nonnull instancetype)applicationControllerWithAuthenticationProvider:(nonnull id<ATLMAuthenticating>)authenticationProvider layerClientOptions:(nullable LYRClientOptions *)layerClientOptions;

/**
 @abstract Updates the application controller with the Layer appID. Updating the
   appID will create and assign an instance of the `LYRClient` on this
   `ATLMApplicationController` instance.
 @param appID The Layer AppID used to initialize an underlying `LYRClient`
   instance.
 @param error An `out` error reference instance will be set in case the
   operation failed.
 @return Returns `YES` if the appID was set and the underlying `LYRClient` instance
   was successfully created; In case the method is called when the appID has
   already been set, the method will return `NO`.
 @warning The appID can be set only once, other attempts will be ignored and the
   method will return `NO` with an error.
 */
- (BOOL)setAppID:(nonnull NSURL *)appID error:(NSError *_Nullable *_Nullable)error;

/**
 @abstract Authenticates the application by performing the Layer authentication handshake.
 @param credentials An `NSDictionary` containing authetication credentials. 
 @param completions A block to be called upon completion of the operation.
 */
- (void)authenticateWithCredentials:(nonnull NSDictionary *)credentials completion:(nonnull void (^)(LYRSession * _Nonnull session, NSError *_Nullable error))completion;

/**
 @abstract Updates the remote notification device token on the underlying `LYRClient` insance.
 @param deviceToken The remote notification device token passed by the app delegate
   upon receiving a device token.
 */
- (void)updateRemoteNotificationDeviceToken:(nullable NSData *)deviceToken;

/**
 @abstract Passes the remote notification to the client to handle it, which
   will cause a short synchronization process and call the completion handler
   once the synchronization completes.
 @param userInfo The remote notification dictionary passed by the app
   delegate upon receiving a remote notification or user responding to it.
 @param completionHandler A block to be called upon completion of the
   synchronization process. The `completionHandler` will always be executed,
   no matter if the underlying client handled the remote notification
   successfully, hit an error, or if the remote notification was not meant
   for the underlying `layerClient`.
 */
- (void)handleRemoteNotification:(nonnull NSDictionary *)userInfo completion:(nonnull void (^)(BOOL success, NSError *_Nullable error))completionHandler;

///-----------------------
/// @name Global Resources
///-----------------------

/**
 @abstract The receiver in charge of handling application state changes and errors.
 */
@property (nullable, nonatomic, weak) id<ATLMApplicationControllerDelegate> delegate;

/**
 @abstract The `LSAPIManager` object for the application.
 */
@property (nonnull, nonatomic, readonly) id<ATLMAuthenticating> authenticationProvider;

/**
 @abstract The Layer appID used to initialize the underlying `LYRClient`.
 */
@property (nullable, nonatomic, readonly) NSURL *appID;

/**
 @abstract The `LYRClient` object for the application.
 */
@property (nullable, nonatomic, readonly) LYRClient *layerClient;

/**
 @abstract The state the application controller is currently in.
 */
@property (assign, nonatomic, readonly) ATLMApplicationState state;

/**
 @abstract Queries the underlying LayerKit client for the total count of `LYRMessage` objects whose `isUnread` property is true.
 */
@property (assign, nonatomic, readonly) NSUInteger countOfUnreadMessages;

/**
 @abstract Queries the underlying LayerKit client for the total count of `LYRMessage` objects.
 */
@property (assign, nonatomic, readonly) NSUInteger countOfMessages;

/**
 @abstract Queries the underlying LayerKit client for the total count of `LYRConversation` objects.
 */
@property (assign, nonatomic, readonly) NSUInteger countOfConversations;

/**
 @abstract Queries LayerKit for an existing message whose `identifier` property matches the supplied identifier.
 @param identifier An NSURL representing the `identifier` property of an `LYRMessage` object for which the query will be performed.
 @retrun An `LYRMessage` object or `nil` if none is found.
 */
- (nullable LYRMessage *)messageForIdentifier:(nonnull NSURL *)identifier;

/**
 @abstract Queries LayerKit for an existing conversation whose `identifier` property matches the supplied identifier.
 @param identifier An NSURL representing the `identifier` property of an `LYRConversation` object for which the query will be performed.
 @retrun An `LYRConversation` object or `nil` if none is found.
 */
- (nullable LYRConversation *)existingConversationForIdentifier:(nonnull NSURL *)identifier;

/**
 @abstract Queries LayerKit for an existing conversation whose `participants` property matches the supplied set.
 @param participants An `NSSet` of participant identifier strings for which the query will be performed.
 @retrun An `LYRConversation` object or `nil` if none is found.
 */
- (nullable LYRConversation *)existingConversationForParticipants:(nonnull NSSet *)participants;


@end
