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

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    if (fileURL == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Failed to initialize `%@` because the `fileURL` argument was `nil`.", self.class];
    }

    self = [super init];
    if (self == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Failed to initialize `%@`.", self.class] userInfo:nil];
    }

    // Load the content of the file in memory.
    NSError *fileReadError;
    NSString *configurationJSON = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&fileReadError];
    if (configurationJSON == nil) {
        // File read failure.
        [NSException raise:NSInternalInconsistencyException format:@"Failed to initialize `%@` because the input file could not be read; error=%@", self.class, fileReadError];
    }
    
    // Deserialize the content of the input file.
    NSError *JSONDeserializationError;
    NSDictionary *configuration;
    configuration = [NSJSONSerialization JSONObjectWithData:[configurationJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&JSONDeserializationError];
    if (!configuration) {
        // Deserialization failure.
        [NSException raise:NSInternalInconsistencyException format:@"Failed to initialize `%@` because the input file could not be deserialized; error=%@", self.class, JSONDeserializationError];
    }
    
    // Extract the appID.
    NSString *appIDString = configuration[ATLMConfigurationAppIDKey];
    if (!appIDString) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to initialize `%@` because `app_id` key in the input file was not set.", self.class];
    }
    if ((id)appIDString == [NSNull null]) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to initialize `%@` because `app_id` key value in the input file was `null`.", self.class];
    }
    _appID = [NSURL URLWithString:appIDString];
    if (!_appID) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to initialize `%@` because `app_id` key value in the input file was not a valid URL. appID='%@'", self.class, appIDString];
    }
    
    // Extract the identity provider URL.
    NSString *identityProviderURLString = configuration[ATLMConfigurationIdentityProviderURLKey];
    if (!identityProviderURLString) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to initialize `%@` because `identity_provider_url` key in the input file was not set.", self.class];
    }
    if ((id)identityProviderURLString == [NSNull null]) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to initialize `%@` because `identity_provider_url` key value in the input file was `null`.", self.class];
    }
    _identityProviderURL = [NSURL URLWithString:identityProviderURLString];
    if (!_identityProviderURL) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to initialize `%@` because `identity_provider_url` key value in the input file was not a valid URL. identityProviderURL='%@'", self.class, identityProviderURLString];
    }
    
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Failed to call designated initializer. Call the designated initializer '%@' on the `%@` instead.", NSStringFromSelector(@selector(initWithFileURL:)), self.class]
                                 userInfo:nil];
}

@end
