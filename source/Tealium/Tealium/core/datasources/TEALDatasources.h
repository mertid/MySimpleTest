//
//  TEALDatasources.h
//  Tealium
//
//  Created by Jason Koo on 8/14/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALDispatch.h"

@interface TEALDatasources : NSObject

- (instancetype) initWithInstanceID:(NSString *) instanceID;

/*
 Data Sources that can be processed in the background
 */
- (NSDictionary *) transmissionTimeDatasourcesForEventType:(TEALDispatchType)eventType;

/*
 Data Sources that are processed and converted to dictionary data at call time - Main Thread
 */
- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALDispatchType)eventType title:(NSString *)title;

// HELPERS

- (NSString *) applicationUUID;

#warning Move to TEALCollect?
- (NSString *) visitorID;

- (NSDictionary *) dataSourcesCopy;

- (void) setDataSources:(NSDictionary *)newDataSources;

@end
