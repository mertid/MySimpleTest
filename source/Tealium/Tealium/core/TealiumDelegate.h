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

- (BOOL) tealium:(Tealium *)tealium shouldSendDispatch:(TEALDispatch *)dispatch;
- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch;
- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch;

@end
