//
//  Tracker.h
//  TealiumiOS
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Tealium.h"
#import "Tealium+Lifecycle.h"
#import "Tealium+Collect.h"
#import "Tealium+TagManagement.h"
#import "Tealium+WatchKit.h"
#import "TealiumDelegate.h"

#import "TEALConfiguration+Collect.h"
#import "TEALConfiguration+Lifecycle.h"
#import "TEALConfiguration+TagManagement.h"
#import "TEALConfiguration.h"
#import "TEALDataSourceConstants.h"
#import "TEALDispatch.h"
#import "TEALRemoteCommandResponse.h"
#import "TEALVisitorProfile.h"
#import "TEALVisitorProfileCurrentVisit.h"
/*
 *  Using an abstract class like this is the recommended best practice for 
 *  utilizing analytics or other third party libraries requiring an event 
 *  trigger with optional data.
 */
@interface TealiumHelper : NSObject <TealiumDelegate>

+ (void) startTracking;

+ (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)data;

+ (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)data;

+ (void) stopTracking;

+ (void) enableRemoteCommandBlock;
    
@end
