//
//  Tracker.h
//  TealiumiOS
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Tealium.h"
#import "Tealium+Collect.h"
#import "Tealium+TagManagement.h"
#import "TealiumDelegate.h"

#import "TEALConfiguration.h"
#import "TEALDataSourceConstants.h"
#import "TEALDispatch.h"
#import "TEALRemoteCommandResponse.h"
#import "TEALSettings.h"
#import "TEALVisitorProfile.h"
#import "TEALVisitorProfileCurrentVisit.h"

/*
 *  This abstract class is the recommended best practice for utilizing analytics
 *  or other third party libraries requiring an event trigger with optional data.
 */
@interface Tracker : NSObject<TealiumDelegate>

+ (void) startTracking;

+ (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)data;

+ (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)data;

+ (void) stopTracking;

@end
