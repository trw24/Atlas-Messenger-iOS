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
#import "ATLMConstants.h"
#import "ATLMessagingUtilities.h"

NSString *const ATLMLayerApplicationID = @"LAYER_APP_ID";
NSString *const ATLMConversationMetadataDidChangeNotification = @"LSConversationMetadataDidChangeNotification";
NSString *const ATLMConversationParticipantsDidChangeNotification = @"LSConversationParticipantsDidChangeNotification";
NSString *const ATLMConversationDeletedNotification = @"LSConversationDeletedNotification";
NSString *const ATLMApplicationControllerErrorDomain = @"ATLMApplicationControllerErrorDomain";

@interface ATLMApplicationController ()

@property (nonnull, nonatomic, readwrite) id<ATLMAuthenticating> authenticationProvider;
@property (nullable, nonatomic, readwrite) NSURL *appID;
@property (nullable, nonatomic, readwrite) LYRClient *layerClient;
@property (assign, nonatomic, readwrite) ATLMApplicationState state;
@property (nonatomic, readwrite, copy) LYRClientOptions *layerClientOptions;

@end

@implementation ATLMApplicationController

+ (instancetype)applicationControllerWithAuthenticationProvider:(id<ATLMAuthenticating>)authenticationProvider layerClientOptions:(LYRClientOptions *)layerClientOptions
{
    return [[self alloc] initWithAuthenticationProvider:authenticationProvider layerClientOptions:layerClientOptions];
}

- (id)initWithAuthenticationProvider:(id<ATLMAuthenticating>)authenticationProvider layerClientOptions:(LYRClientOptions *)layerClientOptions
{
    self = [super init];
    if (self) {
        _authenticationProvider = authenticationProvider;
        _layerClientOptions = layerClientOptions;
        _state = ATLMApplicationStateAppIDNotSet;
        NSString *appIDString = [[NSUserDefaults standardUserDefaults] valueForKey:ATLMLayerApplicationID];
        NSURL *appID = [NSURL URLWithString:appIDString];
        if (appID) {
            [self setAppID:appID error:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setState:(ATLMApplicationState)state
{
    if (_state == state) {
        // Prevent to notify the delegate with the same state.
        return;
    }
    _state = state;
    if ([self.delegate respondsToSelector:@selector(applicationController:didChangeState:)]) {
        [self.delegate applicationController:self didChangeState:state];
    }
}

#pragma mark - LayerKit client initialization and configuration

- (BOOL)setAppID:(nonnull NSURL *)appID error:(NSError *__autoreleasing _Nullable*)error
{
    if (self.appID) {
        // Prevent from re-setting the appID.
        if (error) {
            *error = [NSError errorWithDomain:ATLMApplicationControllerErrorDomain code:ATLMApplicationControllerErrorAppIDAlreadySet userInfo:@{ NSLocalizedDescriptionKey: @"Failed to set the appID because it has been previously set." }];
        }
        return NO;
    }
    _appID = appID;
    
    // Persist the appID into the user defaults.
    [[NSUserDefaults standardUserDefaults] setValue:appID.absoluteString forKey:ATLMLayerApplicationID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Associate the authentication model with the new appID.
    [self.authenticationProvider updateWithAppID:appID];
    
    // Create a new instance of LYRClient and configure it.
    [self initializeLayerClient];
    
    // Bump the application state.
    if (self.layerClient.currentSession.state == LYRSessionStateAuthenticated) {
        self.state = ATLMApplicationStateAuthenticated;
    } else {
        self.state = ATLMApplicationStateCredentialsRequired;
    }
    return YES;
}

- (void)initializeLayerClient
{
    self.layerClient = [LYRClient clientWithAppID:self.appID delegate:self options:self.layerClientOptions];
    self.layerClient.autodownloadMIMETypes = [NSSet setWithObjects:ATLMIMETypeImageJPEGPreview, ATLMIMETypeTextPlain, nil];
    
    // Connect if possible.
    if (!self.layerClient.isConnected && !self.layerClient.isConnecting) {
        [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
            NSLog(@"Layer Client Connected");
        }];
    }
}

- (void)authenticateWithCredentials:(NSDictionary *)credentials completion:(void (^)(LYRSession *session, NSError *error))completion
{
    __weak typeof(self) weakSelf = self;
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString * _Nullable nonce, NSError * _Nullable error) {
        if (!nonce) {
            completion(nil, error);
            return;
        }
        [weakSelf.authenticationProvider authenticateWithCredentials:credentials nonce:nonce completion:^(NSString * _Nonnull identityToken, NSError * _Nonnull error) {
            if (!identityToken) {
                completion(nil, error);
                return;
            }
            [weakSelf.layerClient authenticateWithIdentityToken:identityToken completion:^(LYRIdentity * _Nullable authenticatedUser, NSError * _Nullable error) {
                if (authenticatedUser) {
                    completion(weakSelf.layerClient.currentSession, nil);
                    weakSelf.state = ATLMApplicationStateAuthenticated;
                } else {
                    completion(nil, error);
                }
            }];
        }];
    }];
}

- (void)updateRemoteNotificationDeviceToken:(NSData *)deviceToken
{
    NSError *error;
    BOOL success = [self.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (!success) {
        [self notifyDelegateOfError:error];
    }
}

#pragma mark - Remote notification handling

- (void)handleRemoteNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL success, NSError *_Nullable error))completionHandler
{
    BOOL success = [self.layerClient synchronizeWithRemoteNotification:userInfo completion:^(LYRConversation * _Nullable conversation, LYRMessage * _Nullable message, NSError * _Nullable error) {
        if (conversation || message) {
            completionHandler(YES, nil);
        } else {
            if (error) {
                // In case the client hit an error during the synchronization process.
                completionHandler(NO, error);
            } else {
                // In case the client didn't receive any conversations or messages.
                completionHandler(YES, nil);
            }
        }
    }];
    if (!success) {
        completionHandler(YES, nil);
    }
}

#pragma mark - LYRClientDelegate implementation

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
    NSLog(@"Layer Client did receive an authentication challenge with nonce=%@", nonce);
    [self.authenticationProvider refreshAuthenticationWithNonce:nonce completion:^(NSString * _Nonnull identityToken, NSError * _Nonnull error) {
        if (!identityToken) {
            [self notifyDelegateOfError:error];
            return;
        }
        // Pass the new identity token to the client to reestablish the session.
        [self.layerClient authenticateWithIdentityToken:identityToken completion:^(LYRIdentity * _Nullable authenticatedUser, NSError * _Nullable error) {
            if (!authenticatedUser) {
                [self notifyDelegateOfError:error];
            }
        }];
    }];
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID
{
    NSLog(@"Layer Client did authenticate as userID=%@", userID);
    // Bumping the application state to "authenticated".
    self.state = ATLMApplicationStateAuthenticated;
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client
{
    NSLog(@"Layer Client did deauthenticate");
    // Revert the state back to "AppIDCollected".
    self.state = ATLMApplicationStateCredentialsRequired;
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
    [self notifyDelegateOfError:error];
}

- (void)layerClient:(LYRClient *)client willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit
{
    NSLog(@"Layer Client will attempt to connect after %.2fs; attempt=%lu; maximumAttempts=%lu", delayInterval, attemptNumber, attemptLimit);
    if ([self.delegate respondsToSelector:@selector(applicationController:willAttemptToConnect:afterDelay:maximumNumberOfAttempts:)]) {
        [self.delegate applicationController:self willAttemptToConnect:attemptNumber afterDelay:delayInterval maximumNumberOfAttempts:attemptLimit];
    }
}

- (void)layerClientDidConnect:(LYRClient *)client
{
    NSLog(@"Layer Client did connect");
    if ([self.delegate respondsToSelector:@selector(applicationControllerDidConnect:)]) {
        [self.delegate applicationControllerDidConnect:self];
    }
}

- (void)layerClientDidDisconnect:(LYRClient *)client
{
    NSLog(@"Layer Client did disconnect");
    if ([self.delegate respondsToSelector:@selector(applicationControllerDidConnect:)]) {
        [self.delegate applicationControllerDidDisconnect:self];
    }
}

- (void)layerClient:(LYRClient *)client didLoseConnectionWithError:(NSError *)error
{
    NSLog(@"Layer Client did lose connection");
    if ([self.delegate respondsToSelector:@selector(applicationControllerDidConnect:)]) {
        [self.delegate applicationController:self didLoseConnectionWithError:error];
    }
}

#pragma mark - Helpers

- (void)notifyDelegateOfError:(NSError *)error
{
    if (error) {
        if ([self.delegate respondsToSelector:@selector(applicationController:didFailWithError:)]) {
            [self.delegate applicationController:self didFailWithError:error];
        }
    }
}

- (NSUInteger)countOfUnreadMessages
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    LYRPredicate *unreadPred =[LYRPredicate predicateWithProperty:@"isUnread" predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    LYRPredicate *userPred = [LYRPredicate predicateWithProperty:@"sender.userID" predicateOperator:LYRPredicateOperatorIsNotEqualTo value:self.layerClient.authenticatedUser.userID];
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPred, userPred]];
    return [self.layerClient countForQuery:query error:nil];
}

- (NSUInteger)countOfMessages
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    return [self.layerClient countForQuery:query error:nil];
}

- (NSUInteger)countOfConversations
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    return [self.layerClient countForQuery:query error:nil];
}

- (LYRMessage *)messageForIdentifier:(NSURL *)identifier
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:identifier];
    query.limit = 1;
    return [self.layerClient executeQuery:query error:nil].firstObject;
}

- (LYRConversation *)existingConversationForIdentifier:(NSURL *)identifier
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:identifier];
    query.limit = 1;
    return [self.layerClient executeQuery:query error:nil].firstObject;
}

- (LYRConversation *)existingConversationForParticipants:(NSSet *)participants
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsEqualTo value:participants];
    query.limit = 1;
    return [self.layerClient executeQuery:query error:nil].firstObject;
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