//
//  TEALWKDelegate.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "Tealium+WatchKit.h"

NSString * const TEALWKMessageKey = @"com.tealium.watchkit";
NSString * const TEALWKCommandTrackEventKey = @"com.tealium.track.event";
NSString * const TEALWKCommandTrackViewKey = @"com.tealium.track.view";
NSString * const TEALWKCommandTrackArgumentTitleKey = @"com.tealium.track.title";
NSString * const TEALWKCommandTrackArgumentCustomDataKey = @"com.tealiumtrack.customdata";

@implementation Tealium(WatchKit)

#pragma mark - WC SESSION DELEGATE

- (void)sessionWatchStateDidChange:(WCSession *)session __WATCHOS_UNAVAILABLE{
    
}

/** ------------------------- Interactive Messaging ------------------------- */


- (void)sessionReachabilityDidChange:(WCSession *)session{
    
}


- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message{
    
    NSDictionary *tealiumPayload = message[TEALWKMessageKey];
    
    if (!tealiumPayload) { return; };
    
    
    
    
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler{
    
}


- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData{
    
}


- (void)session:(WCSession *)session didReceiveMessageData:(NSData *)messageData replyHandler:(void(^)(NSData *replyMessageData))replyHandler{
    
}


/** -------------------------- Background Transfers ------------------------- */


- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *, id> *)applicationContext{
    
}


- (void)session:(WCSession * __nonnull)session didFinishUserInfoTransfer:(WCSessionUserInfoTransfer *)userInfoTransfer error:(nullable NSError *)error{
    
}


- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *, id> *)userInfo{
    
}


- (void)session:(WCSession *)session didFinishFileTransfer:(WCSessionFileTransfer *)fileTransfer error:(nullable NSError *)error{
    
}

- (void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file{
    
}


@end
