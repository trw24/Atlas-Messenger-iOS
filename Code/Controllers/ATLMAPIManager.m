//
//  ATLMAPIManager.m
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

#import "ATLMAPIManager.h"
#import "ATLMUser.h"
#import "ATLMHTTPResponseSerializer.h"
#import "ATLMErrors.h"
#import "ATLMAPIManaging.h"
#import "ATLMConstants.h"

@interface ATLMAPIManager () <NSURLSessionDelegate>

@property (nonatomic, readwrite) NSURL *baseURL;
@property (nonatomic, readwrite) LYRClient *layerClient;
@property (nonatomic, readwrite) NSURLSession *URLSession;
@property (nonatomic, readwrite) id <ATLMSession> authenticatedSession;

@end

@implementation ATLMAPIManager

@synthesize persistenceManager = _persistenceManager;
@synthesize delegate = _delegate;

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient
{
    NSParameterAssert(baseURL);
    NSParameterAssert(layerClient);
    return [[self alloc] initWithBaseURL:baseURL layerClient:layerClient];
}

- (id)initWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        _baseURL = baseURL;
        _layerClient = layerClient;
        _URLSession = [self defaultURLSession];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (NSURLSession *)defaultURLSession
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{ @"Accept": @"application/json", @"X_LAYER_APP_ID": self.layerClient.appID.absoluteString };
    return [NSURLSession sessionWithConfiguration:configuration];
}

- (BOOL)resumeSession:(id <ATLMSession>)session error:(NSError *__autoreleasing *)error
{
    if (!session) return NO;
    if (self.authenticatedSession) return YES;
    if (!session) {
        if (error) {
            *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMNoAuthenticatedSession userInfo:@{NSLocalizedDescriptionKey: @"No authenticated session."}];
            return NO;
        }
    }
    self.authenticatedSession = session;
    return YES;
}

- (void)deauthenticate
{
    if (!self.authenticatedSession) return;
    
    self.authenticatedSession = nil;
    
    [self.URLSession invalidateAndCancel];
    self.URLSession = [self defaultURLSession];
    [[NSNotificationCenter defaultCenter] postNotificationName:ATLMUserDidDeauthenticateNotification object:nil];
}

#pragma mark - Registration

- (void)registerUserWithFirstName:(NSString*)firstName lastName:(NSString *)lastName nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSDictionary *userData, NSError *error))completion
{
    NSParameterAssert(firstName);
    NSParameterAssert(lastName);
    NSParameterAssert(nonce);
    NSParameterAssert(completion);
    NSString *displayName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    NSString *appUUID = [[self.layerClient.appID pathComponents] lastObject];
    NSString *urlString = [NSString stringWithFormat:@"apps/%@/atlas_identities", appUUID];
    NSURL *URL = [NSURL URLWithString:urlString relativeToURL:self.baseURL];
    NSDictionary *parameters = @{ @"user" : @{ @"first_name": firstName, @"last_name": lastName, @"display_name": displayName, @"avatar_url": @"" }, @"nonce" : nonce };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!response && error) {
            NSLog(@"Failed with error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, error);
            });
            return;
        }
        
        NSError *serializationError;
        NSDictionary *userDetails;
        BOOL success = [ATLMHTTPResponseSerializer responseObject:&userDetails withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *userData = userDetails[ATLMAtlasIdentityKey];
                NSString *identityToken = userDetails[ATLMAtlasIdentityTokenKey];
                completion(identityToken, userData, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, serializationError);
            });
        }
    }] resume];
}

@end