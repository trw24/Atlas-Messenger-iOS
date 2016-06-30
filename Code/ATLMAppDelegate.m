//
//  ATLMAppDelegate.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/10/14.
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

#import <LayerKit/LayerKit.h>
#import <Atlas/Atlas.h>
#import <MessageUI/MessageUI.h>
#import <sys/sysctl.h>
#import <asl.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "ATLMAppDelegate.h"
#import "ATLMNavigationController.h"
#import "ATLMConversationListViewController.h"
#import "ATLMSplitViewController.h"
#import "ATLMSplashView.h"
#import "ATLMQRScannerController.h"
#import "ATLMUtilities.h"
#import "ATLMConstants.h"
#import "ATLMAuthenticationProvider.h"
#import "ATLMApplicationViewController.h"

static NSString *const ATLMLayerAppID = nil;

@interface ATLMAppDelegate () <MFMailComposeViewControllerDelegate>

@property (nonnull, nonatomic) ATLMApplicationController *applicationController;
@property (nonnull, nonatomic) ATLMApplicationViewController *applicationViewController;

@end

@implementation ATLMAppDelegate

#pragma mark UIApplicationDelegate implementation

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create the authentication provider instance
    ATLMAuthenticationProvider *provider = [ATLMAuthenticationProvider providerWithBaseURL:ATLMRailsBaseURL(ATLMEnvironmentProduction)];
    
    // Configure the Layer Client options.
    LYRClientOptions *clientOptions = [LYRClientOptions new];
    clientOptions.synchronizationPolicy = LYRClientSynchronizationPolicyPartialHistory;
    clientOptions.partialHistoryMessageCount = 20;
    
    // Create the application controller.
    self.applicationController = [ATLMApplicationController applicationControllerWithAuthenticationProvider:provider layerClientOptions:clientOptions];
    if (!self.applicationController.appID) {
        // Application controller has a persistent appID which is stored
        // in NSUserDefaults, and is restored during initialization.
        NSURL *appID = [NSURL URLWithString:ATLMLayerAppID];
        [self.applicationController setAppID:appID error:nil];
    }
    
    // Create the view controller that will also be the root view controller of the app.
    self.applicationViewController = [[ATLMApplicationViewController alloc] initWithApplication:application applicationController:self.applicationController];

    // Put the view controller on screen.
    self.window = [UIWindow new];
    self.window.frame = [[UIScreen mainScreen] bounds];
    self.window.rootViewController = self.applicationViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.applicationViewController refreshApplicationBadgeCount];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Application failed to register for remote notifications with error %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.applicationController updateRemoteNotificationDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self.applicationController handleRemoteNotification:userInfo responseInfo:nil completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            NSLog(@"Failed to handle remote notification with error %@", error);
            completionHandler(UIBackgroundFetchResultFailed);
        }
    }];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler
{
    if (![identifier isEqualToString:ATLUserNotificationInlineReplyActionIdentifier]) {
        // Bail out, if the action identifier is not meant for us.
        return;
    }
    [self.applicationController handleRemoteNotification:userInfo responseInfo:responseInfo completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            NSLog(@"Failed to handle remote notification with response with error %@", error);
            completionHandler(UIBackgroundFetchResultFailed);
        }
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return YES;
}

@end
