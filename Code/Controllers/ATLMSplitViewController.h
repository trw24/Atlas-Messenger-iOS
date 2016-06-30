//
//  ATLMSplitViewController.h
//  Atlas Messenger
//
//  Created by Kabir Mahal on 9/11/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 @abstract Subclass of the `UISplitViewController`. Presents a user interface for the application window.
 */
@interface ATLMSplitViewController : UISplitViewController

/**
 @abstract Sets the main view controller for the split view controller.
 @param mainViewController A `UIViewController` subclass that is the main view controller.
 */
- (void)setMainViewController:(UIViewController *)mainViewController;

/**
 @abstract Sets the detail view controller for the split view controller.
 @param detailViewController A `UIViewController` subclass that is the detail view controller.  Should be set on action in
 main view controller.
 */
- (void)setDetailViewController:(UIViewController *)detailViewController;

@end
