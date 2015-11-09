//
//  Tealium.h
//  Tealium
//
//  Created by George Webster on 7/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TEALConfiguration.h"
#import "TEALDispatch.h"
#import "TealiumDelegate.h"

/**
 *  Tealium is the main class for the Tealium Library.
 *
 *  Currently implements a multiton pattern that permits multiple Tealium instances.
 *
 *  Internally the entire library runs inside its own serial queue so there is no need call Tealium methods from a background thread, it takes care of that on its own.
 *
 */
@interface Tealium : NSObject

# pragma mark - Setup / Configuration

/**
 *  Starts an instance of the Tealium Mobile Library for a given key with the given configuration object.
 *
 *  @param key NSString identifier for the library instance
 *
 *  @param configuration TEALConfiguration instance with valid Account/Profile/Enviroment properties.
 */
+ (_Nullable instancetype) newInstanceForKey:(NSString * _Nonnull)key configuration:(TEALConfiguration * _Nullable)configuration;

#pragma mark - Instance Management
/**
 *  Returns an instance of the library for the given key, or NIL if such an instance has not been previously initialized.
 *
 *  @param key NSString identifier for the library instance.
 */
+ (_Nullable instancetype) instanceForKey:(NSString * _Nonnull)key;

/**
 *  Removes and nils out an instance of the library with the given key.
 *
 *  @param key NSString identifier for the library instance to remove.
 */
+ (void) destroyInstanceForKey:(NSString * _Nonnull)key;

/**
 *  Optional delegate primarily for monitoring or manipulating dispatch data.
 *
 *  @return The current delegate of the library instance
 */
- (id<TealiumDelegate> _Nullable) delegate;

/**
 *  Set the library delegate for overriding and or monitoring dispatch processes.
 */
- (void) setDelegate:(id<TealiumDelegate> _Nullable)delegate;


# pragma mark - Track Data

/**
 *  Sends an event to Collect.  Event are packaged with any custom key/value data sources passed in along with the default datasources provided by the library.
 *
 *  @param title String title of event
 *  @param customDataSources Dictionary of custom datasources (key/value pairs) to be included in the event dispatch.
 */
- (void) trackEventWithTitle:(NSString * _Nullable)title dataSources:(NSDictionary * _Nullable)customDataSources;

/**
 *  Sends a view to Collect.  Views are packaged with any custom key/value data sources passed in along with the default datasources provided by the library.
 *
 *  @param title String title of view
 *  @param customDataSources Dictionary of custom datasources (key/value pairs) to be included in the event dispatch.
 */

- (void) trackViewWithTitle:(NSString * _Nullable)title dataSources:(NSDictionary * _Nullable)customDataSources;


#pragma mark - Data Management

/**
 *  Copy of all non persistent, UI object and dispatch specific data sources captured by a Tealium library instance at time of call.
 *
 *  @return NSDictionary of Tealium Data Source keys and values at time of call.
 */
- (NSDictionary * _Nonnull) volatileDataSourcesCopy;

/**
 *  Adds additional data to the temporary data sources dictionary. This command is added to the end of the current Tealium background queue for writing.
 *
 *  @param additionalDataSources New or overwrite data sources to add to the volatile data sources store.  These key values can only be superceded by the custom data sources added to track calls.
 *
 */
- (void) addVolatileDataSources:(NSDictionary * _Nonnull)additionalDataSources;

/**
 *  Removes key-value pairs from the library instance's volatile memory
 *
 *  @param dataSourceKeys An NSArray of string keys to remove
 */
- (void) removeVolatileDataSourcesForKeys:(NSArray * _Nonnull)dataSourceKeys;

/**
 *  Copy of all long term Tealium data source data written to and read from disk, specific to a given library instance.
 *  
 *  @return NSDictionary of Tealium Data Source keys and values at time of call.
 */
- (NSDictionary * _Nonnull) persistentDataSourcesCopy;

/**
 *  Adds key-value info into the library instance's persistent data store.  Use this to track lifetime values or seldom-changed global data sources.
 *
 *  @param additionalDataSources An NSDictionary of string keys and values.
 */
- (void) addPersistentDataSources:(NSDictionary * _Nonnull)additionalDataSources;

/**
 *  Removes all keys from array parameter.
 *
 *  @param dataSourceKeys An NSArray of strings of the target keys to remove from the persistence store.
 */
- (void) removePersistentDataSourcesForKeys:(NSArray * _Nonnull)dataSourceKeys;



@end
