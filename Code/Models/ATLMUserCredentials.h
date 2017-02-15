//
//  ATLMUserCredentials.h
//  Atlas Messenger
//
//  Created by Daniel Maness on 11/10/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 @abstract The `ATLMUserCredentials` class is a model for a user's credentials, including email and password.
 */
@interface ATLMUserCredentials : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;

/**
 @abstract Designated initializer for `ATLMUserCredentials`
 @param email The user's email
 @param email The user's password
 */
- (instancetype _Nonnull)initWithEmail:(NSString *_Nonnull)email password:(NSString *_Nonnull)password;

/**
 @abstract Returns the credentials as an NSDictionary
 */
- (NSDictionary * _Nonnull)asDictionary;

@end
NS_ASSUME_NONNULL_END
