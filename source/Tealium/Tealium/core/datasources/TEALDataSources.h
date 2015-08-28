//
//  TEALDatasources.h
//  Tealium
//
//  Created by Jason Koo on 8/14/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TEALDispatch.h"

@interface TEALDataSources : NSObject

- (instancetype) initWithInstanceID:(NSString *) instanceID;

#warning BASELINE datasources (combine relevant transmission and capture time data)

/*
 Data Sources that can be processed in the background
 */
- (NSDictionary *) transmissionTimeDatasourcesForEventType:(TEALDispatchType)eventType;

/*
 Data Sources that are processed and converted to dictionary data at call time - Main Thread
 */
- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALDispatchType)eventType title:(NSString *)title;

/*
 // TODO Comments
 */
- (NSDictionary *) persistentDataSources;

/*
 // TODO Comments
 */
- (void) setPersistentDataSources:(NSDictionary *)newDataSources;


// HELPERS

- (NSString *) applicationUUID;

- (NSString *) visitorIDCopy;



@end
