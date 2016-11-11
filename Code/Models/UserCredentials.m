//
//  UserCredentials.m
//  DI Messenger
//
//  Created by Daniel Maness on 11/10/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import "UserCredentials.h"
@import RNCryptor;

static NSString *defaultsEmailKey = @"DEFAULTS_EMAIL";
static NSString *defaultsPasswordKey = @"DEFAULTS_PASSWORD";
// https://xkcd.com/221/
static NSString *encryptionSecret = @"rsRJk2wMKUWkFDkGYyEncw";

@implementation UserCredentials
+ (UserCredentials *)credentialsWithEmail:(NSString *)email password:(NSString *)password {
    UserCredentials *creds = [self new];
    creds.email = email;
    creds.password = password;
    return creds;
}

+ (UserCredentials * _Nullable)savedCredentials {
    NSString *savedEmail = [[NSUserDefaults standardUserDefaults] stringForKey:defaultsEmailKey];
    NSData *encryptedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:defaultsPasswordKey];
    
    // Decode encrypted password
    NSError *error = nil;
    NSData *decodedPassword = [RNCryptor decryptData:encryptedPassword password:encryptionSecret error:&error];
    NSString *savedPassword = [[NSString alloc] initWithData:decodedPassword encoding:NSUTF8StringEncoding];
    if (error) {
        NSLog(@"Error decoding saved password: %@", error);
        return nil;
    }
    return [self credentialsWithEmail:savedEmail password:savedPassword];
}

- (void)saveAndOverwriteExisting {
    // Encrypt password before saving to disk
    NSData *passwordAsData = [self.password dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedPassword = [RNCryptor encryptData:passwordAsData password:encryptionSecret];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.email forKey:defaultsEmailKey];
    [[NSUserDefaults standardUserDefaults] setObject:encryptedPassword forKey:defaultsPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)asDictionary {
    return @{@"email": self.email, @"password": self.password};
}
@end
