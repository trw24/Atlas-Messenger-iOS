//
//  LSRegistrationViewController.m
//  QRCodeTest
//
//  Created by Kevin Coleman on 2/15/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "ATLMRegistrationViewController.h"
#import "ATLLogoView.h"
#import <Atlas/Atlas.h>
#import "ATLMConstants.h"
#import "ATLMUtilities.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ATLMConstants.h"
#import "ATLMErrors.h"  

@interface ATLMRegistrationViewController () <UITextFieldDelegate>

@property (nonatomic) ATLLogoView *logoView;
@property (nonatomic) UITextField *firstNameTextField;
@property (nonatomic) UITextField *lastNameTextField;
@property (nonatomic) NSLayoutConstraint *firstNameTextFieldBottomConstraint;
@property (nonatomic) NSLayoutConstraint *lastNameTextFieldBottomConstraint;

@end

@implementation ATLMRegistrationViewController

CGFloat const ATLMLogoViewBCenterYOffset = 184;
CGFloat const ATLMfirstNameTextFieldWidthRatio = 0.8;
CGFloat const ATLMfirstNameTextFieldHeight = 52;
CGFloat const ATLMfirstNameTextFieldBottomPadding = 20;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.logoView = [[ATLLogoView alloc] init];
    self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.logoView];
    
    self.firstNameTextField = [[UITextField alloc] init];
    self.firstNameTextField .translatesAutoresizingMaskIntoConstraints = NO;
    self.firstNameTextField .delegate = self;
    self.firstNameTextField .placeholder = @"First Name";
    self.firstNameTextField .textAlignment = NSTextAlignmentCenter;
    self.firstNameTextField .layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.firstNameTextField .layer.borderWidth = 0.5;
    self.firstNameTextField .layer.cornerRadius = 2;
    self.firstNameTextField.font = [UIFont systemFontOfSize:22];
    self.firstNameTextField .returnKeyType = UIReturnKeyNext;
    [self.view addSubview:self.firstNameTextField ];
    
    self.lastNameTextField = [[UITextField alloc] init];
    self.lastNameTextField .translatesAutoresizingMaskIntoConstraints = NO;
    self.lastNameTextField .delegate = self;
    self.lastNameTextField .placeholder = @"Last Name";
    self.lastNameTextField .textAlignment = NSTextAlignmentCenter;
    self.lastNameTextField .layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.lastNameTextField .layer.borderWidth = 0.5;
    self.lastNameTextField .layer.cornerRadius = 2;
    self.lastNameTextField.font = [UIFont systemFontOfSize:22];
    self.lastNameTextField .returnKeyType = UIReturnKeyGo;
    [self.view addSubview:self.lastNameTextField ];
    
    [self configureLayoutConstraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.firstNameTextField becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.lastNameTextFieldBottomConstraint.constant = -rect.size.height - ATLMfirstNameTextFieldBottomPadding;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.lastNameTextField) {
        NSString *firstName = self.firstNameTextField.text;
        NSString *lastName = self.lastNameTextField.text;
        [self registerAndAuthenticateUserWithFirstName:firstName lastName:lastName];
    } else {
        [self.lastNameTextField becomeFirstResponder];
    }
    return YES;
}

- (void)registerAndAuthenticateUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    [self.view endEditing:YES];

    // Gather and send the credentials to the delegate.
    NSDictionary *credentials = @{ ATLMFirstNameKey: firstName, ATLMLastNameKey: lastName };
    if ([self.delegate respondsToSelector:@selector(registrationViewController:didSubmitCredentials:)]) {
        [self.delegate registrationViewController:self didSubmitCredentials:credentials];
    }
}

- (void)configureLayoutConstraints
{
    // Logo View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-ATLMLogoViewBCenterYOffset]];
    
    // Registration View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.firstNameTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.firstNameTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:ATLMfirstNameTextFieldWidthRatio constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.firstNameTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMfirstNameTextFieldHeight]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.firstNameTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.lastNameTextField attribute:NSLayoutAttributeTop multiplier:1.0 constant:-ATLMfirstNameTextFieldBottomPadding]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lastNameTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lastNameTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:ATLMfirstNameTextFieldWidthRatio constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lastNameTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLMfirstNameTextFieldHeight]];
    self.lastNameTextFieldBottomConstraint = [NSLayoutConstraint constraintWithItem:self.lastNameTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ATLMfirstNameTextFieldBottomPadding];
    [self.view addConstraint:self.lastNameTextFieldBottomConstraint];
}

@end
