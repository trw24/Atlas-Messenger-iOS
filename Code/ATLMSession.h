//
//  ATLMSession.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/24/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLMAuthenticating.h"

/**
 @abstract The `ATLMSession` protocol must be adopted by object modeling a session in the Atlas Messenger application.
 */
@protocol ATLMSession <NSObject, NSCoding>

/**
 @abstract Returns an object conforming to the `ATLMSession` protocol containing information about the current session.
 @param authenticationToken A token required for communication with the Layer Identity provider.
 @param user an object conforming to the`ATLAuthenticating` protocol.
 */
+ (instancetype)sessionWithAuthenticationToken:(NSString *)authenticationToken user:(id <ATLMAuthenticating>)user;

/**
 @abstract The authentication token for communicating with the Layer Identity Provider.
 */
@property (nonatomic, readonly) NSString *authenticationToken;

/**
 @abstract An object conforming to the `ATLMUser` protocol.
 */
@property (nonatomic, readonly) id <ATLMAuthenticating> user;

@end
