//
//  ATLMUtilities.h
//  Atlas Messenger
//
//  Created by JP McGlone 01/04/2017
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
#import "ATLMConfiguration.h"

NSString *const ATLMConfigurationAppIDKey = @"app_id";
NSString *const ATLMConfigurationIdentityProviderURLKey = @"identity_provider_url";

@implementation ATLMConfiguration

- (instancetype)initWithFileURL: (NSURL *)fileURL
{
    if (!fileURL) {
        [NSException raise:NSInvalidArgumentException format:@"Failed to initialize `ATLMConfiguration` because fileURL was nil"];
    }

    self = [super init];
    if (self) {
        if (fileURL != nil) {
            NSString *configurationJSON = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
            
            NSDictionary *configuration;
            if (configurationJSON != nil) {
                configuration = [NSJSONSerialization JSONObjectWithData:[configurationJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            }
            if (!configuration) {
                [NSException raise:NSInvalidArgumentException format:@"Failed to initialize `ATLMConfiguration` because the configuration was nil"];
            }
            
            NSString *appIDString = configuration[ATLMConfigurationAppIDKey];
            if (!appIDString) {
                [NSException raise:NSInvalidArgumentException format:@"Failed to initialize `ATLMConfiguration` because app_id in the configuration was not set"];
            }
            
            if ((id)appIDString == [NSNull null]) {
                [NSException raise:NSInvalidArgumentException format:@"Failed to initialize `ATLMConfiguration` because app_id in the configuration was null"];
            }
            
            _appID = [NSURL URLWithString:appIDString];
            if (!_appID) {
                [NSException raise:NSInvalidArgumentException format:@"Failed to initialize `ATLMConfiguration` because app_id in the configuration was not a valid URL"];
            }
            
            _identityProviderURL = configuration[ATLMConfigurationIdentityProviderURLKey];
            if (!_identityProviderURL) {
                [NSException raise:NSInvalidArgumentException format:@"Failed to initialize `ATLMConfiguration` because identity_provider_url in the configuration was null"];
            }
        }
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Failed to call designated initializer. Call the designated initializer on the subclass instead."
                                 userInfo:nil];
}

@end
