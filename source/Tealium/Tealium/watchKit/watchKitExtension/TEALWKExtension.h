//
//  TealiumWK.h
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALWKExtensionConfiguration.h"
#import "TEALWKConstants.h"

@protocol TEALWKExtensionDelegate <NSObject>

@optional

/**
 *  Called when the watch is offline / not connected to it's host device.
 *
 *  @param trackData An NSDictionary of metadata and simple datasources for further
 *      processing by the Tealium Library in the host app.
 *  @param count The current queue count that includes this queued call.
 */
- (void) tealiumExtensionDidQueueTrackCall:(NSDictionary * _Nonnull)trackData currentQueueCount:(NSUInteger)count;

/**
 *  Called when the extension has passed a watch track event to the Tealium Library
 *      in the host app.
 *
 *  @param trackData An NSDictionary of metadata and simple datasources for further
 *      processing by the Tealium Library in the host app.
 */
- (void) tealiumExtensionDidHandoffTrackCall:(NSDictionary * _Nonnull)trackData;

/**
 *  Called when the Tealium Extension encouters an issue.
 *
 *  @param trackData An NSDictionary of metadata and simple datasources for further
 *      processing by the Tealium Library in the host app.
 *  @param error NSError with details of any problems encountered by the extension
 */
- (void) tealiumExtensionTrackCall:(NSDictionary * _Nonnull)trackData didEncounterError:(NSError * _Nullable)error;

@end

/**
 *
 *  Add this class to your Watch App Extension. 
 *
 *  On Host app, implementation requirements:
 *      - Tealium Library 5.x
 *      - TEALWKDelegate classes or framework
 *
 */
@interface TEALWKExtension : NSObject

@property (nonatomic, weak) id<TEALWKExtensionDelegate> delegate;

# pragma mark - Setup / Configuration

/**
 *  Starts an instance of the TEALWKExtension.
 *
 *  @param key A unique string identifier for the target matching Tealium instance.
 *  @param configuration A TEALWKExtensionConfiguration object that contains the target account-profile-env settings.
 *
 *  @return TEALWKExtension instance that matches a Tealium instance with the given configuration
 *
 *  @warning *Note:* Only the account-profile-env options will be used, all other configuration options will be ignored.
 */
+ (_Nullable instancetype) newInstanceForKey:(NSString * _Nonnull)key configuration:(TEALWKExtensionConfiguration * _Nonnull)configuration;


#pragma mark - Instance Management
/**
 *
 *  @param key NSString identifier for the library instance.
 *
 *  @return An instance of the TEALWKExtension for calling methods.
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
