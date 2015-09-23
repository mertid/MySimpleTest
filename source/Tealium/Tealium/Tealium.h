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
#import "NSObject+Tealium.h"
#import "TEALSettings.h"

/**
 *  Tealium is the main class for the Tealium Library.
 *
 *  This defines the public API for sending & receiving data through collect and by default audience stream
 *
 *  Currently it is entirely exposed via class methods.  This is done to allow flexabilitiy of changing the implementation.  Currently it is implemented using a singleton instance of the library and sending messages to it's instance methods.
 *  Internally the entire library runs inside its own serial queue so there is no need call Tealium methods from a background thread, it takes care of that on its own.
 *
 */
@interface Tealium : NSObject

@property (readonly, nonatomic) TEALSettings *settings;
@property (weak, nonatomic) id<TealiumDelegate> delegate;

# pragma mark - Setup / Configuration

/**
 *  Starts an instance of the Tealium Mobile Library for a given key with the given configuration object.
 *
 *  @param key NSString identifier for the library instance
 *
 *  @param configuration TEALConfiguration instance with valid Account/Profile/Enviroment properties.
 */
+ (instancetype) newInstanceForKey:(NSString *)key configuration:(TEALConfiguration *)configuration;

#pragma mark - Instance Management
/**
 *  Returns an instance of the library for the given key, or NIL is such an instance has not been previously initialized.
 *
 *  @param key NSString identifier for the library instance.
 */
+ (instancetype) instanceForKey:(NSString *)key;

/**
 *  Removes and nils out an instance of the library with the given key.
 *
 *  @param key NSString identifier for the library instance to remove.
 */
+ (void) destroyInstanceForKey:(NSString *)key;

/**
 *  Disabled the library from operating.  Sets the libraries internal state to disabled, all subsequent method calls with be ignored.
 */
- (void) disable;

/**
 */
- (void) enable;

/**
 
 */
- (BOOL) isEnabled;

# pragma mark - Track Data

/**
 *  Sends an event to Collect.  Event are packaged with any custom key/value data sources passed in along with the default datasources provided by the library.
 *
 *  @param title String title of event
 *  @param customDataSources Dictionary of custom datasources (key/value pairs) to be included in the event dispatch.
 */
- (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)customDataSources;

/**
 *  Sends a view to Collect.  Views are packaged with any custom key/value data sources passed in along with the default datasources provided by the library.
 *
 *  @param title String title of view
 *  @param customDataSources Dictionary of custom datasources (key/value pairs) to be included in the event dispatch.
 */

- (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)customDataSources;


#pragma mark - Data Management

/**
 *  Copy of all non persistent, UI object and dispatch specific data sources captured by a Tealium library instance at time of call.
 *
 *  @return NSDictionary of Tealium Data Source keys and values at time of call.
 */
- (NSDictionary *) volatileDataSourcesCopy;

/**
 *  Adds additional data to the temporary data sources dictionary. This command is added to the end of the current Tealium background queue for writing.
 *
 *  @param additionalDataSources New or overwrite data sources to add to the volatile data sources store.  These key values can only be superceded by the custom data sources added to track calls.
 *
 */
- (void) addVolatileDataSources:(NSDictionary *)additionalDataSources;

/**
 *  Removes key-value pairs from the library instance's volatile memory
 *
 *  @param dataSourceKeys An NSArray of string keys to remove
 */
- (void) removeVolatileDataSourcesForKeys:(NSArray *)dataSourceKeys;

/**
 *  Copy of all long term Tealium data source data written to and read from disk, specific to a given library instance.
 *  
 *  @return NSDictionary of Tealium Data Source keys and values at time of call.
 */
- (NSDictionary *) persistentDataSourcesCopy;

/**
 */
- (void) addPersistentDataSources:(NSDictionary *)additionalDataSources;

/**
 
 */
- (void) removePersistentDataSourcesForKeys:(NSArray *)dataSourceKeys;



@end
