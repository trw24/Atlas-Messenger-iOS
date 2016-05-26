//
//  ATLMApplicationController.m
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

#import "ATLMApplicationController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ATLMErrors.h"
#import "ATLMUser.h"
#import "ATLMConstants.h"

NSString *const ATLMLayerApplicationID = @"LAYER_APP_ID";
NSString *const ATLMConversationMetadataDidChangeNotification = @"LSConversationMetadataDidChangeNotification";
NSString *const ATLMConversationParticipantsDidChangeNotification = @"LSConversationParticipantsDidChangeNotification";
NSString *const ATLMConversationDeletedNotification = @"LSConversationDeletedNotification";

@interface ATLMApplicationController ()

@end

@implementation ATLMApplicationController

+ (instancetype)applicationControllerWithAuthenticationProvider:(id<ATLMAuthenticating>)authenticationProvider
{
    return [[self alloc] initWithAuthenticationProvider:authenticationProvider];
}

- (id)initWithAuthenticationProvider:(id<ATLMAuthenticating>)authenticationProvider
{
    self = [super init];
    if (self) {
        _authenticationProvider = authenticationProvider;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Authentication

- (void)authenticateWithCredentials:(NSDictionary *)credentials completion:(void (^)(LYRSession *session, NSError *error))completion
{
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString * _Nullable nonce, NSError * _Nullable error) {
        if (nonce) {
            completion(nil, error);
        }
        [self.authenticationProvider authenticateWithCredentials:credentials nonce:nonce completion:^(NSString * _Nonnull identityToken, NSError * _Nonnull error) {
            if (identityToken) {
                completion(nil, error);
            }
            [self.layerClient authenticateWithIdentityToken:identityToken completion:^(LYRIdentity * _Nullable authenticatedUser, NSError * _Nullable error) {
                if (authenticatedUser) {
                    completion(nil, error);
                } else {
                    completion(self.layerClient.currentSession, nil);
                }
            }];
        }];
    }];
}

#pragma mark Update Layer Client

- (void)updateWithLayerClient:(nonnull LYRClient *)client
{
    _layerClient = client;
}

#pragma mark - LYRClientDelegate

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
    [self.authenticationProvider refreshAuthenticationWithNonce:nonce completion:^(NSString * _Nonnull identityToken, NSError * _Nonnull error) {
        //
    }];
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID
{
    NSLog(@"Layer Client did recieve authentication nonce");
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client
{
    NSLog(@"Layer Client did deauthenticate");
}

- (void)layerClient:(LYRClient *)client objectsDidChange:(NSArray *)changes
{
    for (LYRObjectChange *change in changes) {
        if (![change.object isKindOfClass:[LYRConversation class]]) {
            continue;
        }
        
        if (change.type == LYRObjectChangeTypeUpdate && [change.property isEqualToString:@"metadata"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationMetadataDidChangeNotification object:change.object];
        }
        
        if (change.type == LYRObjectChangeTypeUpdate && [change.property isEqualToString:@"participants"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationParticipantsDidChangeNotification object:change.object];
        }
        
        if (change.type == LYRObjectChangeTypeDelete) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ATLMConversationDeletedNotification object:change.object];
        }
    }
}

- (void)layerClient:(LYRClient *)client didFailOperationWithError:(NSError *)error
{
    NSLog(@"Layer Client did fail operation with error: %@", error);
}

- (void)layerClient:(LYRClient *)client willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit
{
    if (attemptNumber == 1) {
        [SVProgressHUD showWithStatus:@"Connecting to Layer"];
    } else {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Connecting to Layer in %lus (%lu of %lu)", (unsigned long)ceil(delayInterval), (unsigned long)attemptNumber, (unsigned long)attemptLimit]];
    }
}

- (void)layerClientDidConnect:(LYRClient *)client
{
    [SVProgressHUD showSuccessWithStatus:@"Connected to Layer"];
}

- (void)layerClient:(LYRClient *)client didLoseConnectionWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Lost Connection: %@", error.localizedDescription]];
}

- (void)layerClientDidDisconnect:(LYRClient *)client
{
    [SVProgressHUD showSuccessWithStatus:@"Disconnected from Layer"];
}

#pragma mark - Notification Handlers

- (void)didReceiveLayerClientWillBeginSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveLayerClientDidFinishSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end