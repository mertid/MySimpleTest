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
#import "TEALDatasources.h"
#import "TEALLogger.h"
#import "TEALOperationManager.h"
#import "TEALSettings.h"
#import "TEALURLSessionManager.h"

#warning Move to Audiencestream

#import "TEALVisitorProfile.h"
#import "TEALVisitorProfileCurrentVisit.h"

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

#warning Make readonly if possible - check categories

@property (strong, nonatomic) TEALDatasources *dataSources;
@property (strong, nonatomic) NSArray *dispatchNetworkServices;
@property (strong, nonatomic) TEALLogger *logger;
@property (strong, nonatomic) TEALOperationManager *operationManager;
@property (strong, nonatomic) TEALSettings *settings;
@property (strong, nonatomic) TEALURLSessionManager *urlSessionManager;


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

- (void) enable;

- (BOOL) isEnabled;

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

//- (void) enableModules;

#pragma mark - Data Management

/*
 */
- (NSDictionary *) persistentDataSourcesCopy;

/*
 */
- (void) setPersistentDataSources:(NSDictionary *) newDataSources;


@end
