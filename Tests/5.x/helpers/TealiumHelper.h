//
//  Tracker.h
//  TealiumiOS
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TealiumHelperImports.h"


/*
 *  Using an abstract class like this is the recommended best practice for 
 *  utilizing analytics or other third party libraries requiring an event 
 *  trigger with optional data.
 */
@interface TealiumHelper : NSObject<TealiumDelegate, NSURLSessionDelegate>

/**
 *  Startup the Tealium instance (and any other third party analytics libraries)
 */
+ (void) startTracking;

/**
 *  Triggers an event tracking call - lazy loads the library upon first call.
 *
 *  @param title Any NSString identifier for the event.
 *  @param data An NSDictionary of additional data for Tealium mapping.
 *
 */
+ (void) trackEventWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)data;

/**
 *  Triggers a view tracking call - lazy loads the library upon first call.
 *
 *  @param title Any NSString identifier for the event.
 *  @param data An NSDictionary of additional data for Tealium mapping.
 *
 */
+ (void) trackViewWithTitle:(NSString * _Nonnull)title dataSources:(NSDictionary * _Nullable)data;

/**
 *  Disable all 3rd party libraries.
 */
+ (void) stopTracking;

//  EXAMPLE CUSTOM METHODS - demonstrating options capable by utilizing Tealium APIs

/**
 *  Keeps a persistent, running tally for a given key.
 *
 *  @param key An NSString identifier for the value to increment.
 *  @param number Int value to increment last saved value by.
 */
+ (void) incrementLifetimeValueForKey:(NSString * _Nonnull)key amount:(int)number;

/**
 *  Turn on a remote command block that can be triggered when certain conditions are met - configured in the TIQ Dashboard.
 */
+ (void) enableRemoteCommandBlock;

/**
 *  Forwarding call to be placed in the matching WCSessionDelegate method session:didReceiveMessage:replyHandler:.
 *
 *  @param session WCSession object that received the target message.
 *  @param message NSDictionary containing the message.
 *  @param replyHandler Completion block for optionally returning response.
 *
 */
+ (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nullable void (^)(NSDictionary<NSString *,id> * _Nullable responseMessage))replyHandler;

@end
