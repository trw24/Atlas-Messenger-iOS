//
//  ATLMApplicationViewController.h
//  Atlas Messenger
//
//  Created by Klemen Verdnik on 6/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMApplicationController.h"

/**
 @abstract The `ATLMApplicationViewController` is responsible for taking care
   of the UI. It listens on the `ATLMApplicationController` state changes and
   configures the UI accordingly. It also works with the `UIApplication` to
   setup remote notification registration and updating the icon badge counts.
 */
@interface ATLMApplicationViewController : UIViewController <ATLMApplicationControllerDelegate>

/**
 @abstract It initializes the view controller and sets itself as the delegate
   of the `ATLMApplicationController`. As soon as this view controller is
   added to the UI stack and is loaded, it will present the splash screen
   followed by the view that corresponds to the `ATLMApplicationController`
   current state.
 @param application The `UIApplication` which this view controller uses to
   update application icon's badge count and asks the user for the remote
   notification permissions.
 @param applicationController The application controller in charge of managing
   Layer client and authentication process.
 @return Returns an initialized application view controller.
 */
- (nonnull id)initWithApplication:(nonnull UIApplication *)application applicationController:(nonnull ATLMApplicationController *)applicationController;

/**
 @abstract It counts the total unread messages count and updates the `UIApplication`'s
   application badge count.
 */
- (void)refreshApplicationBadgeCount;

/**
 @abstract The app object this view controller uses to update the badge count and
   request the remote notification permissions.
 */
@property (nonnull, nonatomic, readonly) UIApplication *application;

/**
 @abstract Reference to the application controller view controller works with
   to present the appropriate UI and perform authentication when needed.
 */
@property (nonnull, nonatomic, readonly) ATLMApplicationController *applicationController;

@end
