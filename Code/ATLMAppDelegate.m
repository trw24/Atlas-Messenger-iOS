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
#import "ATLMUserSession.h"
#import "ATLMConstants.h"
#import "ATLMAuthenticationProvider.h"

static NSString *const ATLMLayerAppID = nil;
static NSString *const ATLMPushNotificationSoundName = @"layerbell.caf";

@interface ATLMAppDelegate () <MFMailComposeViewControllerDelegate>

@property (nonatomic) ATLMQRScannerController *scannerController;
@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) ATLMConversationListViewController *conversationListViewController;
@property (nonatomic) ATLMSplashView *splashView;
@property (nonatomic) ATLMLayerClient *layerClient;
@property (nonatomic) ATLMSplitViewController *splitViewController;

@end

@implementation ATLMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Setup the application controller.
    [self setupApplicationController];
    
    // Setup Layer
    [self setupLayerClient];
    
    // Setup notifications
    [self registerNotificationObservers];
    
    // Configure Atlas Messenger UI appearance
    [self configureGlobalUserInterfaceAttributes];
    
    // Set up window
    [self configureWindow];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self setApplicationBadgeNumber];
}

#pragma mark - Setup

- (void)setupApplicationController
{
#warning Replace `ATLMAPIManger` with an object conforming to `ATLAPIManaging` protocol.
    ATLMAuthenticationProvider *provider = [ATLMAuthenticationProvider providerWithBaseURL:ATLMRailsBaseURL(ATLMEnvironmentProduction)];
    self.applicationController = [ATLMApplicationController applicationControllerWithAuthenticationProvider:provider];
}

- (void)setupLayerClient
{
    [[NSUserDefaults standardUserDefaults] setValue:@"layer:///apps/staging/1a607db0-bcb4-11e4-b40f-9b1c0100594f" forKey:ATLMLayerApplicationID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *appID = ATLMLayerAppID ?: [[NSUserDefaults standardUserDefaults] valueForKey:ATLMLayerApplicationID];
    if (!appID) {
        return;
    }
    if (!self.layerClient) {
        NSDictionary *options = @{LYRClientOptionSynchronizationPolicy : @(LYRClientSynchronizationPolicyMessageCount), LYRClientOptionSynchronizationMessageCount: @(10)};
        self.layerClient = [ATLMLayerClient clientWithAppID:[NSURL URLWithString:appID] options:options];
        self.layerClient.autodownloadMIMETypes = [NSSet setWithObjects:ATLMIMETypeImageJPEGPreview, ATLMIMETypeTextPlain, nil];
        [self.applicationController updateWithLayerClient:self.layerClient];
        [(ATLMAuthenticationProvider *)self.applicationController.authenticationProvider updateWithAppID:[NSURL URLWithString:appID]];
    }
    [self connectLayerIfNeeded];
}

- (void)configureWindow
{
    self.splitViewController = [[ATLMSplitViewController alloc] init];
    self.applicationController.splitViewController = self.splitViewController;
    
    self.window = [UIWindow new];
    [self.window makeKeyAndVisible];
    self.window.frame = [[UIScreen mainScreen] bounds];
    self.window.rootViewController = self.splitViewController;

    [self addSplashView];
    
    if (self.layerClient.authenticatedUser) {
        [self presentAuthenticatedLayerSession];
    } else {
        if (self.layerClient.appID) {
            [self presentScannerViewController:YES withAuthenticationController:YES];
        } else {
            [self presentScannerViewController:YES withAuthenticationController:NO];
        }
    }
    [self removeSplashView];
}

- (void)registerNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerAppID:) name:ATLMDidReceiveLayerAppID object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAuthenticate:) name:ATLMUserDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidAuthenticateWithLayer:) name:LYRClientDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDeauthenticate:) name:ATLMUserDidDeauthenticateNotification object:nil];
}

- (void)connectLayerIfNeeded
{
    if (!self.applicationController.layerClient.isConnected && !self.applicationController.layerClient.isConnecting) {
        [self.applicationController.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
            NSLog(@"Layer Client Connected");
        }];
    }
}

#pragma mark - Push Notifications

- (void)registerForRemoteNotifications:(UIApplication *)application
{
    NSSet *categories = nil;
    if ([UIMutableUserNotificationAction instancesRespondToSelector:@selector(behavior)]) {
        categories = [NSSet setWithObject:ATLDefaultUserNotificationCategory()];
    }
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:categories];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
}

- (void)unregisterForRemoteNotifications:(UIApplication *)application
{
    [application unregisterForRemoteNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Application failed to register for remote notifications with error %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSError *error;
    BOOL success = [self.applicationController.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (success) {
        NSLog(@"Application did register for remote notifications");
    } else {
        NSLog(@"Error updating Layer device token for push:%@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    BOOL userTappedRemoteNotification = application.applicationState == UIApplicationStateInactive;
    __block LYRConversation *conversation = [self conversationFromRemoteNotification:userInfo];
    if (userTappedRemoteNotification && conversation) {
        [self navigateToViewForConversation:conversation];
    } else if (userTappedRemoteNotification) {
        [SVProgressHUD showWithStatus:@"Loading Conversation"];
    }
    
    BOOL success = [self.applicationController.layerClient synchronizeWithRemoteNotification:userInfo completion:^(LYRConversation * _Nullable conversation, LYRMessage * _Nullable message, NSError * _Nullable error) {
        if (conversation || message) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(error ? UIBackgroundFetchResultFailed : UIBackgroundFetchResultNoData);
        }
        
        // Try navigating once the synchronization completed
        if (userTappedRemoteNotification && conversation) {
            [SVProgressHUD dismiss];
            [self navigateToViewForConversation:conversation];
        }
    }];
    
    if (!success) {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return YES;
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler
{
    if ([identifier isEqualToString:ATLUserNotificationInlineReplyActionIdentifier]) {
        NSString *responseText = responseInfo[UIUserNotificationActionResponseTypedTextKey];
        if ([responseText length]) {
            LYRConversation *conversation = [self conversationFromRemoteNotification:userInfo];
            if (conversation) {
                LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:responseText];
                NSString *fullName = self.applicationController.layerClient.authenticatedUser.displayName;
                NSString *pushText = [NSString stringWithFormat:@"%@: %@", fullName, responseText];
                LYRMessage *message = ATLMessageForParts(self.applicationController.layerClient, @[ messagePart ], pushText, ATLMPushNotificationSoundName);
                if (message) {
                    NSError *error = nil;
                    BOOL success = [conversation sendMessage:message error:&error];
                    if (!success) {
                        NSLog(@"Failed to send inline reply: %@", [error localizedDescription]);
                    }
                }
            } else {
                NSLog(@"Failed to complete inline reply: unable to find Conversation referenced by remote notification.");
            }
        }
    }
    completionHandler();
}

- (LYRConversation *)conversationFromRemoteNotification:(NSDictionary *)remoteNotification
{
    NSURL *conversationIdentifier = [NSURL URLWithString:[remoteNotification valueForKeyPath:@"layer.conversation_identifier"]];
    return [(ATLMLayerClient *)self.applicationController.layerClient existingConversationForIdentifier:conversationIdentifier];
}

- (void)navigateToViewForConversation:(LYRConversation *)conversation
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.conversationListViewController selectConversation:conversation];
        });
    } else {
        self.conversationListViewController selectConversation:conversation];
    }
}

#pragma mark - Authentication Notification Handlers

- (void)didReceiveLayerAppID:(NSNotification *)notification
{
    [self setupLayerClient];
}

- (void)userDidAuthenticateWithLayer:(NSNotification *)notification
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self userDidAuthenticateWithLayer:notification];
        });
        return;
    }
    [self presentAuthenticatedLayerSession];
}

- (void)userDidAuthenticate:(NSNotification *)notification
{
    [self registerForRemoteNotifications:[UIApplication sharedApplication]];
}

- (void)userDidDeauthenticate:(NSNotification *)notification
{
    [self addSplashView];
    self.splashView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.splashView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.splitViewController dismissViewControllerAnimated:YES completion:^{
            self.conversationListViewController = nil;
            [self.splitViewController resignFirstResponder];
            [self.splitViewController setDetailViewController:[UIViewController new]];
            [self setupLayerClient];
        }];
    }];

    [self unregisterForRemoteNotifications:[UIApplication sharedApplication]];
}

#pragma mark - ScannerView

- (void)presentScannerViewController:(BOOL)animated withAuthenticationController:(BOOL)withAuthenticationController
{
    self.scannerController = [ATLMQRScannerController new];
    self.scannerController.applicationController = self.applicationController;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.scannerController];
    self.navigationController.navigationBarHidden = YES;
    
    [self.splitViewController presentViewController:self.navigationController animated:animated completion:^{
        if (!withAuthenticationController) {
            [self removeSplashView];
        } else {
            [self.scannerController presentRegistrationViewController];
            [self performSelector:@selector(removeSplashView) withObject:nil afterDelay:1.0f];
        }
    }];
}

#pragma mark - Conversations

- (void)presentAuthenticatedLayerSession
{
    if (self.navigationController) {
        [self.splitViewController dismissViewControllerAnimated:YES completion:nil];
    }
    if (self.conversationListViewController) return;
    self.conversationListViewController = [ATLMConversationListViewController conversationListViewControllerWithLayerClient:self.applicationController.layerClient];
    self.conversationListViewController.applicationController = self.applicationController;
    
    ATLMConversationViewController *conversationViewController = [ATLMConversationViewController conversationViewControllerWithLayerClient:self.applicationController.layerClient];
    conversationViewController.applicationController = self.applicationController;
    conversationViewController.displaysAddressBar = YES;
    
    [self.splitViewController setMainViewController:self.conversationListViewController];
    [self.splitViewController setDetailViewController:conversationViewController];
}

#pragma mark - Splash View

- (void)addSplashView
{
    if (!self.splashView) {
        self.splashView = [[ATLMSplashView alloc] initWithFrame:self.window.bounds];
    }
    [self.window addSubview:self.splashView];
}

- (void)removeSplashView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.splashView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.splashView removeFromSuperview];
        self.splashView = nil;
    }];
}

#pragma mark - UI Config

- (void)configureGlobalUserInterfaceAttributes
{
    [[UINavigationBar appearance] setTintColor:ATLBlueColor()];
    [[UINavigationBar appearance] setBarTintColor:ATLLightGrayColor()];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:ATLBlueColor()];
}

#pragma mark - Application Badge Setter

- (void)setApplicationBadgeNumber
{
    NSUInteger countOfUnreadMessages = [(ATLMLayerClient *)self.applicationController.layerClient countOfUnreadMessages];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:countOfUnreadMessages];
}

@end
