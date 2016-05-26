//
//  ATLMAuthenticationProvider.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLMAuthenticating.h"

/*
 @abstract A key whose value should be the first name of an authenticating user.
 */
extern NSString * _Nonnull const ATLMFirstNameKey;

/*
 @abstract A key whose value should be the last name of an authenticating user.
 */
extern NSString * _Nonnull const ATLMLastNameKey;

/**
 @abstract The `ATLMAuthenticationProvider` conforms to the `ATLMAuthenticating` protocol. It provides for making requests to the Layer Identity Provider in order to request identity tokens needed of LayerKit authentication.
 */
@interface ATLMAuthenticationProvider : NSObject <ATLMAuthenticating>

/**
 @abstract The initializer for the `ATLMAuthenticationProvider`.
 @param baseURL The base url for the Layer Identity provider.
 */
+ (nonnull instancetype)providerWithBaseURL:(nonnull NSURL *)baseURL;

/**
 @abstract Updates the `ATLMAuthenticationProvider` with a Layer app ID.
 @param appID The Layer app ID.
 */
- (void)updateWithAppID:(nonnull NSURL *)appID;

@end


