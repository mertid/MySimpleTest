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

+ (NSDictionary *) applicationInfoDataSources;

+ (NSDictionary *) carrierInfoDataSources;

+ (NSDictionary *) deviceInfoDataSources;

+ (NSDictionary *) tealiumInfoDataSources;

+ (NSString *) titleForViewEventWithObject:(NSObject *)obj;

- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALDispatchType)eventType title:(NSString *)title;

- (NSMutableDictionary *) clientVolatileDataSources;

- (NSDictionary *) persistentDataSourcesCopy;

- (void) addPersistentDataSources:(NSDictionary *)additionalDataSources;

- (void) removePersistentDataSourceForKeys:(NSArray *)dataSourceKeys;

- (void) purgePersistentDataSources;

// HELPERS

+ (double) deviceBatteryLevel;

+ (BOOL) deviceIsCharging;

- (NSString *) uuid;

- (NSString *) visitorIDCopy;



@end
