//
//  ATLMPersistenceManager.h
//  Atlas Messenger
//
//  Created by Blake Watters on 6/28/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "ATLMSession.h"
#import "ATLMUser.h"

/**
 @abstract The `ATLMPersistenceManager` provides an interface for persisting and querying, session and user
 data related to the Atlas Messenger application.
 */
@interface ATLMPersistenceManager : NSObject

///---------------------------------------
/// @name Initializing a Manager
///---------------------------------------

/**
 @abstract Returns the default persistence manager for the application.
 @discussion When running within XCTest, returns a transient in-memory persistence manager. When running in a normal application environment, returns a persistence manager that persists objects to disk.
 */
+ (instancetype)defaultManager;

///---------------------------------------
/// @name Persisting
///---------------------------------------

/**
 @abstract Persists an `ATLMSession` object for the currently authenticated user.
 @param session The `ATLMSession` object to be persisted.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value indicating if the operation was successful.
 */
- (BOOL)persistSession:(ATLMSession *)session error:(NSError **)error;

///---------------------------------------
/// @name Fetching
///---------------------------------------

/**
 @abstract Returns the persisted `ATLMSession` object.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 */
- (ATLMSession *)persistedSessionWithError:(NSError **)error;

///---------------------------------------
/// @name Deletion
///---------------------------------------

/**
 @abstract Deletes all objects currently persisted in the persistence manager.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value indicating if the operation was successful.
 */
- (BOOL)deleteAllObjects:(NSError **)error;

@end
