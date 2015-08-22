//
//  Tealium+Collect.h
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#ifndef TEAL_MODULE_COLLECT
#define TEAL_MODULE_COLLECT
#endif

#import "Tealium.h"

#import "TEALVisitorProfile.h"
#import "TEALVisitorProfileCurrentVisit.h"

#import "TEALVisitorProfileBaseAttribute.h"
#import "TEALVisitorProfileAudienceAttribute.h"
#import "TEALVisitorProfileBadgeAttribute.h"
#import "TEALVisitorProfileDateAttribute.h"
#import "TEALVisitorProfileFlagAttribute.h"
#import "TEALVisitorProfileMetricAttribute.h"
#import "TEALVisitorProfilePropertyAttribute.h"

@interface Tealium (Collect)

- (NSURL *) profileURL;

- (NSURL *) profileDefinitionURL;

/**
 *  Copy of the Unique visitor ID per Account / Device combination.
 *
 *  @return String value of the visitorID for the Account the library was enabled with.
 */
- (NSString *) visitorIDCopy;

/**
 *  Last retrieved profile instance.  This is updated every time the profile is queried.  Depending on the settings the library was enabled with, this could be after every sendEvent:customData: call or only on explicit request.
 *
 *  @return Returns valid TEALVisitorProfile object.  Its properties might be nil of nothing is loaded into them yet.
 */
- (TEALVisitorProfile *) cachedVisitorProfileCopy;


/**
 *  Retrieves the current visitor profile from AudienceStream.
 *
 *  @param completion Completion block with retrieved TEALVisitorProfile instance and an error should any problems occur.
 */
- (void) fetchVisitorProfileWithCompletion:(void (^)(TEALVisitorProfile *profile, NSError *error))completion;



/**
 *  Joins a trace initiated from the AudienceStream web app with a valid string token provide from the TraceUI
 *
 *  @param token String value should match the code provided via the AudienceStream web UI.
 */
- (void) joinTraceWithToken:(NSString *)token;

/**
 *  Stops sending trace data for the provided token in the joinTraceWithToken: method.
 */
- (void) leaveTrace;


@end
