//
//  ATLMConstants.m
//  Atlas Messenger
//
//  Created by Kevin Coleman on 2/18/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "ATLMConstants.h"

NSString *const ATLMUserDidAuthenticateNotification = @"ATLMUserDidAuthenticateNotification";
NSString *const ATLMUserDidDeauthenticateNotification = @"ATLMUserDidDeauthenticateNotification";
NSString *const ATLMApplicationDidSynchronizeParticipants = @"ATLMApplicationDidSynchronizeParticipants";

NSString *const ATLMAtlasIdentityKey = @"atlas_identity";
NSString *const ATLMAtlasIdentitiesKey = @"atlas_identities";
NSString *const ATLMAtlasIdentityTokenKey = @"identity_token";

UIFont *ATLMUltraLightFont(CGFloat size)
{
    return [UIFont fontWithName:@"AvenirNext-UltraLight" size:size];
}

UIFont *ATLMLightFont(CGFloat size)
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}
