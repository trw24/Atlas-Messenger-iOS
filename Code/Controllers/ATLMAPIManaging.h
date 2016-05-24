//
//  ATLMAPIManaging.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/24/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "ATLMSession.h"
#import "ATLMPersistenceManaging.h"

/**
 @abstract The `ATLMAPIManaging` protocol must be adopeted by objects wishing to perform authentication network requests in the Atlas Messenger application.
 */
@protocol ATLMAPIManaging <NSObject>

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient;

/**
 @abstract Registers and authenticates an Atlas Messenger user.
 @param name An `NSString` object representing the name of the user attempting to register.
 @param nonce A nonce value obtained via a call to `requestAuthenticationNonceWithCompletion:` on `LYRClient`.
 @param completion completion The block to execute upon completion of the asynchronous user registration operation.
 */
- (void)registerUserWithFirstName:(NSString*)firstName lastName:(NSString *)lastName nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSDictionary *userData, NSError *error))completion;

/**
 @disucssion Informs the manager that a session should be resumed.
 @param session The session object to be resumed.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value that indicates whether or not the operation was successful.
 */
- (BOOL)resumeSession:(id <ATLMSession>)session error:(NSError **)error;

/**
 @abstract Deauthenticates the Atlas Messenger app by discarding its `ATLMSession` object.
 */
- (void)deauthenticate;

/**
 @abstract The baseURL used to initialize the receiver.
 */
@property (nonatomic, readonly) NSURL *baseURL;

/**
 @abstract The `LYRClient` object used to initialize the receiver.
 */
@property (nonatomic, readonly) LYRClient *layerClient;

/**
 @abstract The currently configured URL session.
 */
@property (nonatomic, readonly) NSURLSession *URLSession;

/**
 @abstract The persistence manager responsible for persisting user information.
 */
@property (nonatomic, readonly) id <ATLMPersistenceManaging> persistenceManager;

/**
 @abstract The current authenticated session or `nil` if not yet authenticated.
 */
@property (nonatomic, readonly) id <ATLMSession> authenticatedSession;


@end
