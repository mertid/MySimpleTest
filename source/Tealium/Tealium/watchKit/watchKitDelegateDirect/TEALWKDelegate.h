//
//  TEALWKDelegate.h
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "Tealium.h"

@import WatchConnectivity;

/**
 *  Call this class's class methods from your WCSessionDelegate.
 */
@interface TEALWKDelegate : NSObject

/*
 *  Using same method names as WCSessionDelegate for simplicity. When used with
    the TEALWKExtension class, these methods can be called (relatively) safely
    without interfering with the app's designated WCSessionDelegate.  These 
    methods looks for the TEALCommandTrack.. keys and will ignore all other
    messages.
 */

/** 
 *  Called on the delegate of the receiver. Will be called on startup if the
    incoming message caused the receiver to launch.
 */
+ (void)session:(WCSession *)session
didReceiveMessage:(NSDictionary<NSString *, id> *)message;

/** 
 *  Called on the delegate of the receiver when the sender sends a message that
    expects a reply. Will be called on startup if the incoming message caused the
    receiver to launch. 
 */
+ (void)session:(WCSession *)session
didReceiveMessage:(NSDictionary<NSString *, id> *)message
   replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler;


@end
