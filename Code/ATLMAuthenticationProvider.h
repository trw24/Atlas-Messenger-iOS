//
//  ATLMAuthenticationProvider.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
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
