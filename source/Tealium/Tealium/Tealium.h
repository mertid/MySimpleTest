//
//  Tealium.h
//  Tealium
//
//  Created by George Webster on 7/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// Configuration

#import "TEALConfiguration.h"

// Profile

#import "TEALVisitorProfile.h"
#import "TEALVisitorProfileCurrentVisit.h"

// Attributes:

#import "TEALVisitorProfileBaseAttribute.h"
#import "TEALVisitorProfileAudienceAttribute.h"
#import "TEALVisitorProfileBadgeAttribute.h"
#import "TEALVisitorProfileDateAttribute.h"
#import "TEALVisitorProfileFlagAttribute.h"
#import "TEALVisitorProfileMetricAttribute.h"
#import "TEALVisitorProfilePropertyAttribute.h"

// Dispatch
#import "TEALDispatch.h"

#import "TEALBlocks.h"
#import "TealiumDelegate.h"

#import "NSObject+Tealium.h"

/**
 *  Tealium is the main class for the Tealium Library.
 *
 *  This defines the public API for sending & receiving data through collect and by default audience stream
 *
 *  Currently it is entirely exposed via class methods.  This is done to allow flexabilitiy of changing the implementation.  Currently it is implemented using a singleton instance of the library and sending messages to it's instance methods.
 *  Internally the entire library runs inside its own serial queue so there is no need call Tealium methods from a background thread, it takes care of that on its own.
 *
 */
@interface Tealium : NSObject

# pragma mark - Setup / Configuration

/**
 *  Starts the Tealium Mobile Library with the given configuration object.
 *
 *  @param configuration TEALConfiguration instance with valid Account/Profile/Enviroment properties.
 */
+ (instancetype) instanceWithConfiguration:(TEALConfiguration *)configuration;

/**
 *  Starts the singleton shared instance of the Tealium Mobile Library with the given configuration object.
 *
 *  @param configuration TEALConfiguration instance with valid Account/Profile/Enviroment properties.
 */
+ (instancetype) sharedInstanceWithConfiguration:(TEALConfiguration *)configuration;

/**
 
 */
+ (instancetype) sharedInstance;

/**
 
 */
+ (void) destroySharedInstance;

/**
 *  Disabled the library from operating.  Sets the libraries internal state to disabled, all subsequent method calls with be ignored.
 */
- (void) disable;

// TODO: comments
@property (weak, nonatomic) id<TealiumDelegate> delegate;

# pragma mark - Track Data

/**
 *  Sends an event to Collect.  Event are packaged with any custom key/value data sources passed in along with the default datasources provided by the library.
 *
 *  @param title String title of event
 *  @param customDataSources Dictionary of custom datasources (key/value pairs) to be included in the event dispatch.
 */
- (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)customDataSources;

/**
 *  Sends a view to Collect.  Views are packaged with any custom key/value data sources passed in along with the default datasources provided by the library.
 *
 *  @param title String title of view
 *  @param customDataSources Dictionary of custom datasources (key/value pairs) to be included in the event dispatch.
 */

- (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)customDataSources;

# pragma mark - AudienceStream

/**
 *  Retrieves the current visitor profile from AudienceStream.
 *
 *  @param completion Completion block with retrieved TEALVisitorProfile instance and an error should any problems occur.
 */
- (void) fetchVisitorProfileWithCompletion:(void (^)(TEALVisitorProfile *profile, NSError *error))completion;

/**
 *  Last retrieved profile instance.  This is updated every time the profile is queried.  Depending on the settings the library was enabled with, this could be after every sendEvent:customData: call or only on explicit request.
 *
 *  @return Returns valid TEALVisitorProfile object.  Its properties might be nil of nothing is loaded into them yet.
 */
- (TEALVisitorProfile *) cachedVisitorProfileCopy;

/**
 *  Copy of the Unique visitor ID per Account / Device combination.
 *
 *  @return String value of the visitorID for the Account the library was enabled with.
 */
- (NSString *) visitorIDCopy;

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

#pragma mark - Tag Management

/**
 *  The UIWebView instance used by the internal tag management system.
 *
 *  @return UIWebView if the remote publish settings tag management toggle is TRUE, otherwise will return nil.
 */
- (UIWebView *) webView;

/*
 */
- (NSDictionary *) persistentDataSourcesCopy;

/*
 */
- (void) setPersistentDataSources:(NSDictionary *) newDataSources;


@end
