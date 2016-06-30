//
//  ATLMSplitViewController.m
//  Atlas Messenger
//
//  Created by Kabir Mahal on 9/11/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "ATLMSplitViewController.h"
#import "ATLMNavigationController.h"
#import "ATLMConversationViewController.h"

@interface ATLMSplitViewController ()

@property (strong, nonatomic) ATLMNavigationController *mainNavigationController;
@property (strong, nonatomic) ATLMNavigationController *detailNavigationController;

@end

@implementation ATLMSplitViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.mainNavigationController = [[ATLMNavigationController alloc] initWithRootViewController:[UIViewController new]];
    self.detailNavigationController = [[ATLMNavigationController alloc] initWithRootViewController:[UIViewController new]];
    self.viewControllers = @[ self.mainNavigationController, self.detailNavigationController ];
}

- (void)setMainViewController:(UIViewController *)mainViewController
{
    mainViewController = mainViewController ?: [[ATLMNavigationController alloc] initWithRootViewController:[UIViewController new]];
    [self.mainNavigationController setViewControllers:@[ mainViewController ]];
}

- (void)setDetailViewController:(ATLMConversationViewController *)detailViewController
{
    BOOL shouldDisplayDetailViewController = !([self.detailNavigationController.viewControllers[0] isMemberOfClass:[UIViewController class]]);
    
    if (shouldDisplayDetailViewController) {
        self.detailNavigationController = [[ATLMNavigationController alloc] initWithRootViewController:detailViewController ?: [UIViewController new]];
        [self showDetailViewController:self.detailNavigationController sender:self];
    } else {
        self.detailNavigationController.viewControllers = @[ detailViewController ?: [[ATLMNavigationController alloc] initWithRootViewController:[UIViewController new]] ];
    }
}

@end
