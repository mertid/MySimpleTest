//
//  TealiumWK.h
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALConfiguration.h"
#import "TealiumDelegate.h"

@interface TealiumWKExtension : NSObject

# pragma mark - Setup / Configuration

/**
 *  Starts an instance of the TealiumWKExtension.
 *
 *  @param key A unique string identifier for the target matching Tealium instance.
 *  @param configuration A TEALConfiguration object that contains the target account-profile-env settings.
 *
 *  @return TealiumWKExtension instance that matches a Tealium instance with the given configuration
 *
 *  @warning *Note:* Only the account-profile-env options will be used, all other configuration options will be ignored.
 */
+ (_Nullable instancetype) newInstanceForKey:(NSString * _Nonnull)key configuration:(TEALConfiguration * _Nullable)configuration;


#pragma mark - Instance Management
/**
 *
 *  @param key NSString identifier for the library instance.
 *
 *  @return An instance of the TealiumWKExtension for calling methods.
 */
+ (_Nullable instancetype) instanceForKey:(NSString * _Nonnull)key;

/**
 *  Removes and nils out an instance of the library with the given key.
 *
 *  @param key NSString identifier for the library instance to remove.
 */
+ (void) destroyInstanceForKey:(NSString * _Nonnull)key;

#warning Not needed with extension?
///**
// *  Optional delegate primarily for monitoring or manipulating dispatch data.
// *
// *  @return The current delegate of the library instance
// */
//- (id<TealiumDelegate> _Nullable) delegate;
//
///**
// *  Set the library delegate for overriding and or monitoring dispatch processes.
// *
// *  @param delegate Any object that implements one or more optional Tealium Delegate
// *  protocols.
// */
//- (void) setDelegate:(id<TealiumDelegate> _Nullable)delegate;


# pragma mark - Track Data

/**
 *  Sends an event to Collect.  Event are packaged with any custom key/value
 *  data sources passed in along with the default datasources provided by the library.
 *
 *  @param title String title of event
 *  @param customDataSources Dictionary of custom datasources (key/value pairs)
 *  to be included in the event dispatch. If a value is an array, be sure to use
 *  an array of strings.
 */
- (void) trackEventWithTitle:(NSString * _Nullable)title dataSources:(NSDictionary * _Nullable)customDataSources;

/**
 *  Sends a view to Collect.  Views are packaged with any custom key/value data
 *  sources passed in along with the default datasources provided by the library.
 *
 *  @param title String title of view
 *  @param customDataSources Dictionary of custom datasources (key/value pairs)
 *  to be included in the event dispatch. If a value is an array, be sure to use
 *  an array of strings.
 */

- (void) trackViewWithTitle:(NSString * _Nullable)title dataSources:(NSDictionary * _Nullable)customDataSources;


#pragma mark - Data Management

///**
// *  Copy of all non persistent, UI object and dispatch specific data sources
// *  captured by a Tealium library instance at time of call.
// *
// *  @return NSDictionary of Tealium Data Source keys and values at time of call.
// */
//- (NSDictionary * _Nonnull) volatileDataSourcesCopy;

/**
 *  Adds additional data to the temporary data sources dictionary. This command
 *  is added to the end of the current Tealium background queue for writing.
 *
 *  @param additionalDataSources New or overwrite data sources to add to the
 *  volatile data sources store.  These key values can only be superceded by the
 *  custom data sources added to track calls. If a value is an array, be sure to use
 *  an array of strings.
 *
 */
- (void) addVolatileDataSources:(NSDictionary * _Nonnull)additionalDataSources;

/**
 *  Removes key-value pairs from the library instance's volatile memory
 *
 *  @param dataSourceKeys An NSArray of string keys to remove
 */
- (void) removeVolatileDataSourcesForKeys:(NSArray * _Nonnull)dataSourceKeys;

///**
// *  Copy of all long term Tealium data source data written to and read from disk,
// *  specific to a given library instance.
// *
// *  @return NSDictionary of Tealium Data Source keys and values at time of call.
// */
//- (NSDictionary * _Nonnull) persistentDataSourcesCopy;

/**
 *  Adds key-value info into the library instance's persistent data store.  Use
 *  this to track lifetime values or seldom-changed global data sources.
 *
 *  @param additionalDataSources An NSDictionary of string keys and values. If
 *  a value is an array, be sure to use an array of strings.
 */
- (void) addPersistentDataSources:(NSDictionary * _Nonnull)additionalDataSources;

/**
 *  Removes all keys from array parameter.
 *
 *  @param dataSourceKeys An NSArray of strings of the target keys to remove
 *  from the persistence store.
 */
- (void) removePersistentDataSourcesForKeys:(NSArray * _Nonnull)dataSourceKeys;




@end
