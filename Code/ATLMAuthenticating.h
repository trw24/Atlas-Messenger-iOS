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
@protocol ATLMAuthenticating <NSObject, NSCoding, ATLParticipant>

/**
 @abstract Builds the object conforming to `ATLMAuthenticating` from a dictionary representation, usually a JSON payload.
 */
+ (instancetype)userFromDictionaryRepresentation:(NSDictionary *)representation;

/**
 @abstract Validates the object conforming to `ATLMAuthenticating` is valid.
 */
- (BOOL)validate:(NSError **)error;

/**
 @abstract An email address for the user.
 */
@property (nonatomic, readonly) NSString *email;

/**
 @abstract The password for the user.
 */
@property (nonatomic, readonly) NSString *password;

/**
 @abstract The password confirmation for the user.
 */
@property (nonatomic, readonly) NSString *passwordConfirmation;

@end


