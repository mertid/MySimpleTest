//
//  TealiumDelegate.h
//  Tealium
//
//  Created by Jason Koo on 7/22/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tealium;
@class TEALDispatch;

@protocol TealiumDelegate <NSObject>

@optional

/**
 *  Delegate method that permits last minute manipulation or suppression (destruction)
 *      of a track call dispatch.
 *
 *  @param tealium The Tealium instance requesting confirmation
 *  @param dispatch The dispatch in question. Property and payload data manipulated
 *          here will overwrite this dispatch's outbound data - effects not
 *          persistent
 *
 *  @return Boolean indicating whether dispatch should be sent or destroyed
 */
- (BOOL) tealium:(Tealium *)tealium shouldSendDispatch:(TEALDispatch *)dispatch;

/**
 *  Dispatches approved by the tealium:shouldSendDispatch: delegate method can be
 *      queued / saved by this method.  Also supercedes any remote publish setting
 *      batching and offline options.
 *
 *  @param tealium The Tealium instance requesting confirmation
 *  @param dispatch The dispatch in question. Property and payload data manipulated
 *          here will overwrite this dispatch's outbound data - effects not
 *          persistent
 *
 *  @bool Boolean indicating whether dispatch should be queued at this time.
 */
- (BOOL) tealium:(Tealium *)tealium shouldQueueDispatch:(TEALDispatch *)dispatch;

/**
 *
 *
 *  @param tealium The Tealium instance requesting confirmation
 *  @param dispatch The dispatch in question. Do not manipulate any of its
 *          properties or payload data here as they will not take effect or
 *          persist.
 *
 */
- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch;

/**
 *
 *
 *  @param tealium The Tealium instance requesting confirmation
 *  @param dispatch The dispatch in question. Do not manipulate any of its 
 *          properties or payload data here as they will not take effect or
 *          persist.
 *
 */
- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch;

@end
