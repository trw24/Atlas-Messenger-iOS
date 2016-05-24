//
//  ATLMPersistenceManaging.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 5/24/16.
//  Copyright © 2016 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLMSession.h"

/**
 @abstract The `ATLMPersistenceManaging` protocol must be adopted by object wishing to perform persitence operations in the Atlas Messenger Application.
 */
@protocol ATLMPersistenceManaging <NSObject>

/**
 @abstract Returns the default persistence manager for the application.
 @discussion When running within XCTest, returns a transient in-memory persistence manager. When running in a normal application environment, returns a persistence manager that persists objects to disk.
 */
+ (instancetype)defaultManager;

/**
 @abstract Persists an `ATLMSession` object for the currently authenticated user.
 @param session The `ATLMSession` object to be persisted.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value indicating if the operation was successful.
 */

- (BOOL)persistSession:(id <ATLMSession>)session error:(NSError **)error;

/**
 @abstract Returns the persisted `ATLMSession` oSbject.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 */
- (id <ATLMSession>)persistedSessionWithError:(NSError **)error;

/**
 @abstract Deletes all objects currently persisted in the persistence manager.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value indicating if the operation was successful.
 */
- (BOOL)deleteSession:(NSError **)error;

@end
