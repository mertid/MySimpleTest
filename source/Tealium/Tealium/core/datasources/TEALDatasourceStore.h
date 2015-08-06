//
//  TEALDatasourceStore.h
//  TealiumUtilities
//
//  Created by George Webster on 4/8/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALDispatch.h"

@interface TEALDatasourceStore : NSObject

+ (instancetype) sharedStore;

- (id) objectForKey:(id<NSCopying, NSSecureCoding>)key;

- (void) setObject:(id<NSCopying, NSSecureCoding>)object
            forKey:(id<NSCopying, NSSecureCoding>)aKey;

- (id) objectForKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

- (void) setObject:(id)obj forKeyedSubscript:(id <NSCopying, NSSecureCoding>)key;

- (BOOL) unarchiveWithStorageKey:(NSString *)key;
- (void) archiveWithStorageKey:(NSString *)key;

- (void) loadWithUUIDKey:(NSString *)key;

- (NSDictionary *) systemInfoDatasources;

- (NSDictionary *) transmissionTimeDatasourcesForEventType:(TEALDispatchType)eventType;

- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALDispatchType)eventType title:(NSString *)title;

@end
