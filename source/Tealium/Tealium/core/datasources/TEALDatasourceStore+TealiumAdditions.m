//
//  TEALDatasourceStore+TealiumAdditions.m
//  Tealium Mobile Library
//
//  Created by George Webster on 4/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDatasourceStore+TealiumAdditions.h"

#import <UIKit/UIDevice.h>
#import "TEALSystemHelpers.h"
#import "TEALNetworkHelpers.h"
#import "NSDate+TealiumAdditions.h"
#import "NSString+TealiumAdditions.h"

static NSString * const kTEALAudienceStreamDatasourceStorageKey = @"com.tealium.audiencestream.datasources";


@implementation TEALDatasourceStore (TealiumAdditions)

- (void) loadWithUUIDKey:(NSString *)key {
    
    NSString *storagekey = [kTEALAudienceStreamDatasourceStorageKey copy];
    if (![self unarchiveWithStorageKey:storagekey]) {
        
        [self addStaticDatasource];
    }
    
    [self addSystemDatasources];
    
    [TEALDatasourceStore sharedStore][TEALDatasourceKey_UUID] = [TEALSystemHelpers applicationUUIDWithKey:key];
    
    [self archiveWithStorageKey:kTEALAudienceStreamDatasourceStorageKey];
}


- (void) addStaticDatasource {
    
    self[TEALDatasourceKey_EventName]          = @"mobile_link";
    self[TEALDatasourceKey_Pagetype]           = @"mobile_view";
    self[TEALDatasourceKey_Platform]           = @"ios";
}

- (void) addSystemDatasources {
    
    self[TEALDatasourceKey_SystemVersion]      = [[UIDevice currentDevice] systemVersion];
    self[TEALDatasourceKey_LibraryVersion]     = [TEALSystemHelpers collectLibraryVersion];
    self[TEALDatasourceKey_ApplicationName]    = [TEALSystemHelpers applicationName];
}

- (NSDictionary *) systemInfoDatasources {

    NSMutableDictionary *datasources = [self datasourcesForKeys:@[TEALDatasourceKey_Platform,
                                                                  TEALDatasourceKey_SystemVersion,
                                                                  TEALDatasourceKey_LibraryVersion]];
    
    datasources[TEALDatasourceKey_Timestamp] = [[NSDate date] teal_timestampISOStringValue];

    return datasources;
}

- (NSMutableDictionary *) datasourcesForKeys:(NSArray *)keys {
    
    NSMutableDictionary *datasources = [NSMutableDictionary new];

    for (id key in keys) {
        
        id obj = self[key];

        if (obj) {
            datasources[key] = obj;
        }
    }
    return datasources;
}

- (NSDictionary *) transmissionTimeDatasourcesForEventType:(TEALEventType)eventType {
    
    NSMutableDictionary *datasources = [NSMutableDictionary new];

    NSDictionary *systemInfo = [self systemInfoDatasources];
    
    [datasources addEntriesFromDictionary:systemInfo];
    
    datasources[TEALDatasourceKey_CallType]         = [TEALNetworkHelpers eventStringFromType:eventType];
    datasources[TEALDatasourceKey_ApplicationName]  = self[TEALDatasourceKey_ApplicationName];

    switch (eventType) {
        case TEALEventTypeLink:
            datasources[TEALDatasourceKey_EventName] = self[TEALDatasourceKey_EventName];
            break;
        case TEALEventTypeView:
            datasources[TEALDatasourceKey_Pagetype] = self[TEALDatasourceKey_Pagetype];
            break;
        default:
            break;
    }
    
    return datasources;
}

- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALEventType)eventType title:(NSString *)title {

    NSMutableDictionary *datasources = [NSMutableDictionary new];

    datasources[TEALDatasourceKey_Timestamp] = [[NSDate date] teal_timestampISOStringValue];
    if (title) {
        switch (eventType) {
            case TEALEventTypeLink:
                datasources[TEALDatasourceKey_EventTitle] = title;
                break;
            case TEALEventTypeView:
                datasources[TEALDatasourceKey_ViewTitle] = title;
                break;
            default:
                break;
        }
    }
    
    return datasources;
}


- (NSDictionary *) queuedFlagWithValue:(BOOL)value {
    
    NSString *displayString = [NSString teal_stringFromBool:value];
    
    return @{ @"was_queued" : displayString };
}

@end
