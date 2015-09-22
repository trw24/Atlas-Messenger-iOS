//
//  ATLMSplitViewController.h
//  Atlas Messenger
//
//  Created by Kabir Mahal on 9/11/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLMConversationListViewController.h"
#import "ATLMConversationViewController.h"
#import "ATLMNavigationController.h"

@interface ATLMSplitViewController : UISplitViewController

- (void)setMainViewController:(UIViewController *)mainViewController;

- (void)setDetailViewController:(UIViewController *)detailViewController;

@end
