//
//  ATLMUserCredentials.h
//  Atlas Messenger
//
//  Created by Daniel Maness on 11/10/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATLMUserCredentials : NSObject
@property (strong, nonatomic) NSString *_Nonnull email;
@property (strong, nonatomic) NSString *_Nonnull password;

+ (ATLMUserCredentials *_Nonnull)credentialsWithEmail:(NSString *_Nonnull)email password:(NSString *_Nonnull)password;
+ (ATLMUserCredentials * _Nullable)savedCredentials;
- (void)saveAndOverwriteExisting;
- (NSDictionary * _Nonnull)asDictionary;
@end
