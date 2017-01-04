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
static NSString *_appID;

+ (void)parseConfigurationIfNeeded {
    if (_configuration == nil) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"Layerfile" ofType:nil];
        NSString *configurationJSON = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        _configuration = [NSJSONSerialization JSONObjectWithData:[configurationJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    }
}

+ (NSString *)appID
{
    [self parseConfigurationIfNeeded];
    if (_appID == nil) {
        id appID = _configuration[@"appID"];
        if (appID != [NSNull null]) {
            _appID = appID;
        }
    }
    return _appID;
}

@end
