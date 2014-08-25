//
//  LSAppController.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/30/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LSApplicationController.h"
#import "LSConversationListViewController.h"
#import "LSUtilities.h"

@interface LSApplicationController () <LYRClientDelegate>

@property (nonatomic) NSURL *baseURL;

@end

@implementation LSApplicationController

+ (instancetype)controllerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient persistenceManager:(LSPersistenceManager *)persistenceManager
{
    NSParameterAssert(baseURL);
    NSParameterAssert(layerClient);
    return [[self alloc] initWithBaseURL:baseURL layerClient:layerClient persistenceManager:persistenceManager];
}

- (id)initWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient persistenceManager:(LSPersistenceManager *)persistenceManager
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        _layerClient.delegate = self;
        _persistenceManager = persistenceManager;
        _APIManager = [LSAPIManager managerWithBaseURL:baseURL layerClient:layerClient];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerClientWillBeginSynchronizationNotification:) name:LYRClientWillBeginSynchronizationNotification object:layerClient];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerClientDidFinishSynchronizationNotification:) name:LYRClientDidFinishSynchronizationNotification object:layerClient];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
{
     NSLog(@"Layer Client did recieve authentication challenge with nonce: %@", nonce);
    LSUser *user = self.APIManager.authenticatedSession.user;
    if (user) {
        [self.APIManager authenticateWithEmail:user.email password:user.password completion:^(LSUser *user, NSError *error) {
            if (user && !error) {
                NSLog(@"silent auth successful");
            } else {
                [self.APIManager deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                    NSLog(@"Silent auth failed, deauthenticating");
                }];
            }
        }];
    }
}

- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID
{
    NSLog(@"Layer Client did recieve authentication nonce");
}

- (void)layerClientDidDeauthenticate:(LYRClient *)client
{
    NSLog(@"Layer Client did deauthenticate");
}

- (void)layerClient:(LYRClient *)client didFinishSynchronizationWithChanges:(NSArray *)changes
{
    NSLog(@"Layer Client did finish sychronization");
}

- (void)layerClient:(LYRClient *)client didFailSynchronizationWithError:(NSError *)error
{
    NSLog(@"Layer Client did fail synchronization with error: %@", error);
}

- (void)didReceiveLayerClientWillBeginSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didReceiveLayerClientDidFinishSynchronizationNotification:(NSNotification *)notification
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

+ (NSString *)versionString
{
    NSString *marketingVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *bundleVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];

    NSDictionary *buildInformation = [[NSBundle mainBundle] infoDictionary][@"LYRBuildInformation"];

    NSString *versionString = nil;
    if (buildInformation) {
        NSString *layerKitVersion = buildInformation[@"LYRBuildLayerKitVersion"];
        versionString = [NSString stringWithFormat:@"LayerSample v%@ (%@) - LayerKit v%@", marketingVersion, bundleVersion, layerKitVersion];
    } else {
        versionString = [NSString stringWithFormat:@"LayerSample v%@ (%@)", marketingVersion, bundleVersion];
    }

    return versionString;
}

+ (NSString *)buildInformationString
{
    NSDictionary *buildInformation = [[NSBundle mainBundle] infoDictionary][@"LYRBuildInformation"];

    if (!buildInformation) {
        return [NSString stringWithFormat:@"Non-Release Build"];
    }

    NSString *buildSHA = buildInformation[@"LYRBuildShortSha"];
    NSString *builderName = buildInformation[@"LYRBuildBuilderName"];
    NSString *builderEmail = buildInformation[@"LYRBuildBuilderEmail"];

    return [NSString stringWithFormat:@"Built by %@ (%@) SHA: %@", builderName, builderEmail, buildSHA];
}

@end
