//
//  TEALWKExtensionDelegate.h
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/11/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

@import Foundation;

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