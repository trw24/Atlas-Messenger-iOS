//
//  ATLMAuthenticating.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/24/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Atlas/Atlas.h>

/**
 @abstract The `ATLMATLMAuthenticating` protocol must be adopted by objects that model users in the Atlas Messenger application.
 */
@protocol ATLMAuthenticating <NSObject>

@required

- (void)authenticateWithCredentials:(nonnull NSDictionary *)credentials nonce:(nonnull NSString *)nonce completion:(void (^)( NSString * _Nonnull identityToken,  NSError * _Nonnull error))completion;

- (void)refreshAuthenticationWithNonce:(nonnull NSString *)nonce completion:(void (^)( NSString * _Nonnull  identityToken,  NSError * _Nonnull error))completion;

@end
