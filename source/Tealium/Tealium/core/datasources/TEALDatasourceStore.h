//
//  TEALDatasourceStore.h
//  TealiumUtilities
//
//  Created by George Webster on 4/8/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: Handles persistent datasources

#import <Foundation/Foundation.h>

#import "TEALDispatch.h"

@interface TEALDatasourceStore : NSObject

- (instancetype) initWithInstanceID:(NSString *) instanceID;

- (id) objectForKey:(id<NSCopying, NSSecureCoding>)key;

- (void) setObject:(id<NSCopying, NSSecureCoding>)object
            forKey:(id<NSCopying, NSSecureCoding>)aKey;

- (id) objectForKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

- (void) setObject:(id)obj forKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

//- (BOOL) unarchiveWithStorageKey:(NSString *)key;
//
//- (void) archiveWithStorageKey:(NSString *)key;

- (void) setDataSources:(NSDictionary *)newDataSources;

- (NSDictionary *) systemInfoDatasources;

- (NSDictionary *) transmissionTimeDatasourcesForEventType:(TEALDispatchType)eventType;

- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALDispatchType)eventType title:(NSString *)title;

- (NSDictionary *) dataSourcesCopy;

- (NSString *) applicationUUID;

- (NSString *) visitorID;

@end
