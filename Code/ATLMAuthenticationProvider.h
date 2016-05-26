//
//  ATLMAuthenticationProvider.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/26/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLMAuthenticating.h"

extern NSString *const ATLMFirstNameKey;
extern NSString *const ATLMLastNameKey;

@interface ATLMAuthenticationProvider : NSObject <ATLMAuthenticating>

+ (nonnull instancetype)providerWithBaseURL:(nonnull NSURL *)baseURL;

- (void)updateWithAppID:(nonnull NSURL *)appID;

@end


