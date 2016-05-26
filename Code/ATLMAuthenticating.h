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
 @abstract The `ATLMAuthenticating` protocol must be adopted by objects that model users in the Atlas Messenger application.
 */
@protocol ATLMAuthenticating <NSObject>

@required

/**
 @abstract Requests an identity token required for Layer authentication with the supplied credentials and nonce.
 @param credentials An `NSDictionary` containing the credentials needed to request the identity token.
 @param nonce A nonce required for the identity token.
 @param completion A block to be called upon completion of the operation.
 */
- (void)authenticateWithCredentials:(nonnull NSDictionary *)credentials nonce:(nonnull NSString *)nonce completion:(nonnull void (^)( NSString * _Nonnull identityToken,  NSError * _Nonnull error))completion;

/**
 @abstract Requests a new identity token with the supplied nonce.
 @param nonce A nonce required for the identity token.
 @param completion A block to be called upon completion of the operation.
 */
- (void)refreshAuthenticationWithNonce:(nonnull NSString *)nonce completion:(nonnull void (^)( NSString * _Nonnull  identityToken,  NSError * _Nonnull error))completion;

@end
