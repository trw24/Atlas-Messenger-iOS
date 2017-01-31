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

@implementation ATLMConfiguration

static NSDictionary *_configuration;
static NSURL *_appID;
static NSURL *_identityProviderURL;

+ (void)initialize
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"LayerConfiguration.json" ofType:nil];
    if (filePath != nil) {
        NSString *configurationJSON = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (configurationJSON != nil) {
            _configuration = [NSJSONSerialization JSONObjectWithData:[configurationJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        }
    }
}

+ (NSURL *)appID
{
    if (_appID == nil) {
        id appIDString = _configuration[@"app_id"];
        if (appIDString != [NSNull null]) {
            _appID = [NSURL URLWithString:appIDString];
        }
    }
    return _appID;
}

+ (NSURL *)identityProviderURL
{
    if (_identityProviderURL == nil) {
        id identityProviderURLString = _configuration[@"identity_provider_url"];
        if (identityProviderURLString != [NSNull null]) {
            _identityProviderURL = [NSURL URLWithString:identityProviderURLString];
        }
    }
    return _identityProviderURL;
}

@end
