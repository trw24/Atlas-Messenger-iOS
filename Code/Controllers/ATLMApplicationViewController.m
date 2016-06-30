//
//  ATLMApplicationViewController.m
//  Atlas Messenger
//
//  Created by Klemen Verdnik on 6/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "ATLMApplicationViewController.h"
#import "ATLMSplashView.h"
#import "ATLMQRScannerController.h"
#import "ATLMRegistrationViewController.h"
#import "ATLMConversationListViewController.h"
#import "ATLMConversationViewController.h"
#import "ATLMUtilities.h"
#import "ATLMSplitViewController.h"
#import "ATLMNavigationController.h"

@interface ATLMApplicationViewController () <ATLMQRScannerControllerDelegate, ATLMRegistrationViewControllerDelegate, ATLMConversationListViewControllerPresentationDelegate>

@property (nonnull, nonatomic, readwrite) UIApplication *application;
@property (nonnull, nonatomic, readwrite) ATLMApplicationController *applicationController;
@property (nullable, nonatomic) ATLMSplashView *splashView;
@property (nullable, nonatomic) ATLMQRScannerController *QRCodeScannerController;
@property (nullable, nonatomic) UINavigationController *registrationNavigationController;
@property (nullable, nonatomic) ATLMSplitViewController *splitViewController;
@property (nullable, nonatomic) ATLMConversationListViewController *conversationListViewController;

@end

@implementation ATLMApplicationViewController

- (nonnull id)initWithApplication:(nonnull UIApplication *)application applicationController:(nonnull ATLMApplicationController *)applicationController
{
    self = [super init];
    if (self) {
        _application = application;
        _applicationController = applicationController;
        _applicationController.delegate = self;
    }
    return self;
}

- (void)refreshApplicationBadgeCount
{
    NSUInteger countOfUnreadMessages = [self.applicationController countOfUnreadMessages];
    [self.application setApplicationIconBadgeNumber:countOfUnreadMessages];
}

- (void)registerForRemoteNotifications
{
    NSSet *categories = nil;
    if ([UIMutableUserNotificationAction instancesRespondToSelector:@selector(behavior)]) {
        categories = [NSSet setWithObject:ATLDefaultUserNotificationCategory()];
    }

    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:categories];
    [self.application registerUserNotificationSettings:notificationSettings];
    [self.application registerForRemoteNotifications];
}

- (void)unregisterForRemoteNotifications
{
    [self.application unregisterForRemoteNotifications];
}

#pragma mark - UIViewController Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeSplashViewVisible:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self presentViewControllerForApplicationState:self.applicationController.state];
}

#pragma mark - Splash View

- (void)makeSplashViewVisible:(BOOL)visible
{
    if (visible) {
        // Add ATLMSplashView to the self.view
        if (!self.splashView) {
            self.splashView = [[ATLMSplashView alloc] initWithFrame:self.view.bounds];
        }
        [self.view addSubview:self.splashView];
    } else {
        // Fade out self.splashView and remove it from the self.view subviews' stack.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.splashView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.splashView removeFromSuperview];
                self.splashView = nil;
            }];
        });
    }
}

#pragma mark - UI view controller presenting

- (void)presentRegistrationNavigationController
{
    if (!self.registrationNavigationController) {
        self.registrationNavigationController = [[UINavigationController alloc] init];
        self.registrationNavigationController.navigationBarHidden = YES;
        if (!self.childViewControllers.count) {
            // Only if there's no child view controller being presented on top.
            [self presentViewController:self.registrationNavigationController animated:YES completion:nil];
        }
        [self.splitViewController removeFromParentViewController];
        [self.splitViewController.view removeFromSuperview];
        self.splitViewController = nil;
        self.conversationListViewController = nil;
    }
}

- (void)presentQRCodeScannerViewController
{
    if (!self.registrationNavigationController) {
        [self presentRegistrationNavigationController];
    }
    ATLMQRScannerController *QRCodeScannerController = [ATLMQRScannerController new];
    QRCodeScannerController.delegate = self;
    [self.registrationNavigationController pushViewController:QRCodeScannerController animated:NO];
}

- (void)presentRegistrationViewController
{
    if (!self.registrationNavigationController) {
        [self presentRegistrationNavigationController];
    }
    ATLMRegistrationViewController *registrationViewController = [ATLMRegistrationViewController new];
    registrationViewController.delegate = self;
    [self.registrationNavigationController pushViewController:registrationViewController animated:YES];
}

- (void)presentConversationListViewController
{
    [self.registrationNavigationController dismissViewControllerAnimated:YES completion:nil];
    self.registrationNavigationController = nil;
    
    // Add splitview controller onto the current view.
    self.splitViewController = [[ATLMSplitViewController alloc] init];
    [self addChildViewController:_splitViewController];
    [self.view addSubview:_splitViewController.view];
    [self.splitViewController didMoveToParentViewController:self];
    
    // And have the conversation view controller be the detail view controller.
    ATLMConversationViewController *conversationViewController = [ATLMConversationViewController conversationViewControllerWithLayerClient:self.applicationController.layerClient];
    [self.splitViewController setDetailViewController:conversationViewController];
    
    // Put the conversation list view controller as the main view controller
    // in the split view.
    self.conversationListViewController = [ATLMConversationListViewController conversationListViewControllerWithLayerClient:self.applicationController.layerClient splitViewController:self.splitViewController];
    self.conversationListViewController.presentationDelegate = self;
    [self.splitViewController setMainViewController:self.conversationListViewController];
}

#pragma mark - Managing UI view transitions

- (void)presentViewControllerForApplicationState:(ATLMApplicationState)applicationState
{
    [self makeSplashViewVisible:YES];
    switch (applicationState) {
        case ATLMApplicationStateAppIDNotSet:{
            [self unregisterForRemoteNotifications];
            [self presentQRCodeScannerViewController];
            break;
        }
        case ATLMApplicationStateCredentialsRequired: {
            [self unregisterForRemoteNotifications];
            [self presentRegistrationViewController];
            break;
        }
        case ATLMApplicationStateAuthenticated: {
            [self registerForRemoteNotifications];
            [self presentConversationListViewController];
            break;
        }
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Unhandled ATLMApplicationState value=%lu", (NSUInteger)applicationState];
            break;
    }
}

#pragma mark - ATLMQRScannerControllerDelegate implementation

- (void)scannerController:(ATLMQRScannerController *)scannerController didReceiveAppID:(NSURL *)appID
{
    NSLog(@"Received an appID=%@ from the scannerController=%@", appID, scannerController);
    // Update the application controller with the appID recevied from the QR code scanner.
    NSError *error;
    BOOL success = [self.applicationController setAppID:appID error:&error];
    if (!success) {
        ATLMAlertWithError(error);
    }
}

- (void)scannerController:(ATLMQRScannerController *)scannerController didFailWithError:(NSError *)error
{
    ATLMAlertWithError(error);
}

#pragma mark - ATLMRegistrationViewControllerDelegate implementation

- (void)registrationViewController:(ATLMRegistrationViewController *)registrationViewController didSubmitCredentials:(NSDictionary *)credentials
{
    [self.applicationController authenticateWithCredentials:credentials completion:^(LYRSession *_Nonnull session, NSError *_Nullable error) {
        if (!session && error) {
            NSLog(@"Failed to authenticate with credentials=%@", credentials);
            ATLMAlertWithError(error);
        }
    }];
}

#pragma mark - ATLMConversationListViewControllerPresentationDelegate implementation

- (void)conversationListViewControllerWillBeDismissed:(nonnull ATLConversationListViewController *)conversationListViewController
{
    // Prepare the current view controller for dismissal of the
    [self makeSplashViewVisible:YES];
    [self.splitViewController setDetailViewController:nil];
}

- (void)conversationListViewControllerWasDismissed:(nonnull ATLConversationListViewController *)conversationListViewController
{
    [self presentViewController:self.registrationNavigationController animated:YES completion:nil];
}

#pragma mark - ATLMApplicationControllerDelegate implementation

- (void)applicationController:(ATLMApplicationController *)applicationController didChangeState:(ATLMApplicationState)applicationState
{
    // Handle UI transitions
    [self presentViewControllerForApplicationState:applicationState];
}

- (void)applicationController:(ATLMApplicationController *)applicationController didFinishHandlingRemoteNotificationForConversation:(LYRConversation *)conversation message:(LYRMessage *)message
{
    // Navigate to the conversation, after the remote notification's been handled.
    BOOL userTappedRemoteNotification = self.application.applicationState == UIApplicationStateInactive;
    if (userTappedRemoteNotification && conversation) {
        [self.conversationListViewController selectConversation:conversation];
    } else if (userTappedRemoteNotification) {
        [SVProgressHUD showWithStatus:@"Loading Conversation"];
    }
}

- (void)applicationController:(ATLMApplicationController *)applicationController didFailWithError:(NSError *)error
{
    // Prompt user of error if necessary
    NSLog(@"Application controller=%@ has hit an error=%@", applicationController, error);
}

- (void)applicationController:(ATLMApplicationController *)applicationController willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit
{
    // Show HUD with message
    if (attemptNumber == 1) {
        [SVProgressHUD showWithStatus:@"Connecting to Layer"];
    } else {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Connecting to Layer in %lus (%lu of %lu)", (unsigned long)ceil(delayInterval), (unsigned long)attemptNumber, (unsigned long)attemptLimit]];
    }
}

- (void)applicationControllerDidConnect:(ATLMApplicationController *)applicationController
{
    // Show HUD with message
    [SVProgressHUD showWithStatus:@"Connected to Layer"];
}

- (void)applicationControllerDidDisconnect:(ATLMApplicationController *)applicationController
{
    // Show HUD with message
    [SVProgressHUD showWithStatus:@"Disconnected from Layer"];
}

- (void)applicationController:(ATLMApplicationController *)applicationController didLoseConnectionWithError:(NSError *)error
{
    // Show HUD with message
    [SVProgressHUD showErrorWithStatus:@"Lost connection from Layer"];
}

@end
