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

- (void) tealiumDidFinishLoadingRemoteSettings:(Tealium *) tealium; // TODO: Delete

- (BOOL) tealium:(Tealium *)tealium shouldSendDispatch:(TEALDispatch *)dispatch;
- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch;
- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch;
- (void) tealium:(Tealium *)tealium didDestroyDisptach:(TEALDispatch *)dispatch; // TODO: Delete

@end
