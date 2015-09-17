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

/*
 *  Current carrier info if CoreTelephony framework available
 */
+ (NSDictionary *) carrierInfoDataSources;

/*
 *  Device information
 */
+ (NSDictionary *) deviceInfoDataSources;

/*
 *  Title for object, intended for view track calls
 *
 *  @param obj Any NSObject
 *
 *  @return NSString title for given object. Returns the object class if no other title type found.
 */
+ (NSString *) titleForViewEventWithObject:(NSObject *)obj;

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
- (void) addPersistentDataSources:(NSDictionary *)additionalDataSources;


/*
 // TODO Comments
 */
- (void) removePersistentDataSourceForKeys:(NSArray *)dataSourceKeys;


// HELPERS

- (NSString *) applicationUUID;

- (NSString *) visitorIDCopy;



@end
