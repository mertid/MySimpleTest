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

@property BOOL disableApplicationInfo;
@property BOOL disableCarrierInfo;
@property BOOL disableDeviceInfo;
@property BOOL disableTealiumInfo;
@property BOOL disableTimestampInfo;


+ (NSDictionary *) dispatchDatasourcesForEventType:(TEALDispatchType)eventType title:(NSString *)title;

+ (double) deviceBatteryLevel;

+ (BOOL) deviceIsCharging;

+ (NSString *)resetSessionID:(NSDate * __nonnull )date;


/**
 *  Returns a dictionary of the timestamp formats from the argument date
 *
 *  @param date Can be an NSDate or an NSString representation of a date
 *
 *  @return dictionary with the requested data
 */
+ (NSDictionary *) timestampDataSourcesForDate:(id)date;

- (instancetype) initWithInstanceID:(NSString *) instanceID;

- (NSDictionary *) mainThreadDataSources;

- (NSDictionary *) backgroundSafeDataSources;

- (NSDictionary *) fetchQueryStringDataSources;

- (NSMutableDictionary *) clientVolatileDataSources;

- (NSDictionary *) persistentDataSources;

- (void) addPersistentDataSources:(NSDictionary *)additionalDataSources;

- (void) removePersistentDataSourceForKeys:(NSArray *)dataSourceKeys;

- (void) purgePersistentDataSources;

- (NSString *) uuid;

- (NSString *) visitorIDCopy;



@end
