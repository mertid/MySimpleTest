//
//  TealiumWK.h
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALConfiguration.h"

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
- (void) trackEventWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)customDataSources;

/**
 *  Sends a view to Collect.  Views are packaged with any custom key/value data
 *  sources passed in along with the default datasources provided by the library.
 *
 *  @param title String title of view
 *  @param customDataSources Dictionary of custom datasources (key/value pairs)
 *  to be included in the event dispatch. If a value is an array, be sure to use
 *  an array of strings.
 */
- (void) trackViewWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)customDataSources;





@end
