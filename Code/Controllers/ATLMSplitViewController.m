//
//  ATLMSplitViewController.m
//  Atlas Messenger
//
//  Created by Kabir Mahal on 9/11/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "ATLMSplitViewController.h"
#import "ATLMNavigationController.h"

@interface ATLMSplitViewController ()

@property (strong, nonatomic) ATLMNavigationController *mainNavigationController;
@property (strong, nonatomic) ATLMNavigationController *detailNavigationController;

@end

@implementation ATLMSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.mainNavigationController = [[ATLMNavigationController alloc] initWithRootViewController:[UIViewController new]];
    self.detailNavigationController = [[ATLMNavigationController alloc] initWithRootViewController:[UIViewController new]];
    self.viewControllers = @[ self.mainNavigationController, self.detailNavigationController ];
}

- (void)setMainViewController:(UIViewController *)mainViewController
{
    [self.mainNavigationController setViewControllers:@[ mainViewController ]];
}

- (void)setDetailViewController:(ATLMConversationViewController *)detailViewController
{
    BOOL shouldDisplayDetailViewController = !([self.detailNavigationController.viewControllers[0] isMemberOfClass:[UIViewController class]]);
    self.detailNavigationController.viewControllers = @[detailViewController];
    
    if (shouldDisplayDetailViewController) {
        [self showDetailViewController:self.detailNavigationController sender:self];
     }
}

@end
