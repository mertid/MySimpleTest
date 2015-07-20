//
//  TEALDatasourceStore+TealiumAdditions.h
//  Tealium Mobile Library
//
//  Created by George Webster on 4/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDatasourceStore.h"
#import "TEALDatasources.h"
#import "TEALEvent.h"

@interface TEALDatasourceStore (TealiumAdditions)

- (void) loadWithUUIDKey:(NSString *)key;

- (NSDictionary *) systemInfoDatasources;

- (NSDictionary *) transmissionTimeDatasourcesForEventType:(TEALEventType)eventType;

- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALEventType)eventType;

@end
