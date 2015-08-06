//
//  TEALDatasourceStore.m
//  TealiumUtilities
//
//  Created by George Webster on 4/8/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIDevice.h>
#import "TEALDatasourceStore.h"
#import "TEALDatasources.h"
#import "TEALSystemHelpers.h"
#import "NSDate+Tealium.h"
#import "NSString+Tealium.h"
#import "TEALLogger.h"


//static NSString * const kTEALMobileDatasourceStorageKey = @"com.tealium.mobile.datasources";

const char * kTEALDatasourceStoreQueueName = "com.tealium.datasource-store-queue";

@interface TEALDatasourceStore ()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) NSMutableDictionary *datasources;

@property (nonatomic, strong) NSString *instanceID;

@end

@implementation TEALDatasourceStore

//+ (instancetype) sharedStore {
//    
//    static dispatch_once_t onceToken = 0;
//    __strong static TEALDatasourceStore *_sharedStore = nil;
//    
//    dispatch_once(&onceToken, ^{
//        _sharedStore = [[TEALDatasourceStore alloc] initPrivate];
//    });
//    
//    return _sharedStore;
//}
//- (instancetype) initPrivate {
//
//    self = [super init];
//
//    if (self) {
//        _queue = dispatch_queue_create(kTEALDatasourceStoreQueueName, DISPATCH_QUEUE_CONCURRENT);
//        _datasources = [NSMutableDictionary new];
//    }
//    return self;
//}
//- (void) loadWithUUIDKey:(NSString *)key {
//
//    NSString *storagekey = [kTEALMobileDatasourceStorageKey copy];
//
//    if (![self unarchiveWithStorageKey:storagekey]) {
//
//        [self addStaticDatasource];
//    }
//
//    [self addSystemDatasources];
//
//    [TEALDatasourceStore sharedStore][TEALDatasourceKey_UUID] = [TEALSystemHelpers applicationUUIDWithKey:key];
//
//    [self archiveWithStorageKey:kTEALMobileDatasourceStorageKey];
//}

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString *) instanceID {
    
    if (!instanceID) {
        TEAL_LogNormal(@"DatasourceStore initialization attempted without an instance ID.");
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _queue = dispatch_queue_create(kTEALDatasourceStoreQueueName, DISPATCH_QUEUE_CONCURRENT);
        _datasources = [NSMutableDictionary new];
        _instanceID = instanceID;
        [self unarchiveWithStorageKey:instanceID];
    }
    return self;
}

- (id) objectForKey:(id<NSCopying, NSSecureCoding>)key {
    
    __block id obj = nil;
    
    dispatch_sync(self.queue, ^{
        obj = self.datasources[key];
    });
    
    return obj;
}

- (id) objectForKeyedSubscript:(id <NSCopying, NSSecureCoding>)key {
    return [self objectForKey:key];
}

- (void) setObject:(id<NSCopying, NSSecureCoding>)object
            forKey:(id<NSCopying, NSSecureCoding>)aKey {
    
    dispatch_barrier_async(self.queue, ^{
        
        self.datasources[aKey] = object;
    });
}

- (void) setObject:(id)obj forKeyedSubscript:(id <NSCopying, NSSecureCoding>)key {
    [self setObject:obj
             forKey:key];
}

#pragma mark - I/O

- (BOOL) unarchiveWithStorageKey:(NSString *)key {
    
    __block BOOL unarchived = NO;
    
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        dispatch_barrier_sync(self.queue, ^{
            [self.datasources addEntriesFromDictionary:obj];
            unarchived = YES;
        });
    }
    return unarchived;
}

- (void) archiveWithStorageKey:(NSString *)key {
    
    __block NSDictionary *dataCopy = nil;
    
    dispatch_barrier_sync(self.queue, ^{
        dataCopy = [self.datasources copy];
    });
    
    if (dataCopy) {
        [[NSUserDefaults standardUserDefaults] setObject:dataCopy
                                                  forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) setDataSources:(NSDictionary *)newDataSources {
    dispatch_barrier_sync(self.queue, ^{
        [self.datasources removeAllObjects];
        [self.datasources addEntriesFromDictionary:newDataSources];
        [self archiveWithStorageKey:self.instanceID];
    });
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

- (NSDictionary *) transmissionTimeDatasourcesForEventType:(TEALDispatchType)eventType {
    
    NSMutableDictionary *datasources = [NSMutableDictionary new];
    
//    NSDictionary *systemInfo = [self systemInfoDatasources];
//    
//    [datasources addEntriesFromDictionary:systemInfo];
//    
//    datasources[TEALDatasourceKey_CallType]         = [TEALDispatch stringFromDispatchType:eventType];
//    datasources[TEALDatasourceKey_ApplicationName]  = self[TEALDatasourceKey_ApplicationName];
//    
//    switch (eventType) {
//        case TEALDispatchTypeEvent:
//            datasources[TEALDatasourceKey_EventName] = self[TEALDatasourceKey_EventName];
//            break;
//        case TEALDispatchTypeView:
//            datasources[TEALDatasourceKey_Pagetype] = self[TEALDatasourceKey_Pagetype];
//            break;
//        default:
//            break;
//    }
    
    return datasources;
}

- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALDispatchType)eventType title:(NSString *)title {
    
    NSMutableDictionary *datasources = [NSMutableDictionary new];
    
    datasources[TEALDatasourceKey_Timestamp] = [[NSDate date] teal_timestampISOStringValue];
    
    if (title) {
        switch (eventType) {
            case TEALDispatchTypeEvent:
                datasources[TEALDatasourceKey_EventTitle] = title;
                break;
            case TEALDispatchTypeView:
                datasources[TEALDatasourceKey_ViewTitle] = title;
                break;
            default:
                break;
        }
    }
    
    datasources[TEALDatasourceKey_Autotracked] = TEALDatasourceValue_False;
    
    return datasources;
}

- (NSDictionary *) dataSourcesCopy {
    return [self.datasources copy];
}

- (NSString *) applicationUUID {
    
    NSString *applicationUUID = self.datasources[TEALDatasourceKey_UUID];
    
    if (!applicationUUID) {
        applicationUUID = [[NSUUID UUID] UUIDString];
        
        self.datasources[TEALDatasourceKey_UUID] = applicationUUID;
    }
    
    return applicationUUID;
}

- (NSString *) visitorID {
    NSString *uuid = [self applicationUUID];
    
    if (![uuid isKindOfClass:([NSString class])]) {
        return nil;
    }
    
    return [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

#pragma mark - PRIVATE INSTANCE METHODS

- (instancetype) init {
    [NSException raise:@"Should not be initialized directly"
                format:@"Please use initWithInstanceID method."];
    return nil;
}

- (void) addStaticDatasource {
    
    self[TEALDatasourceKey_EventName]   = TEALDatasourceValue_EventName;
    self[TEALDatasourceKey_Pagetype]    = TEALDatasourceValue_Pagetype;
    self[TEALDatasourceKey_Platform]    = TEALDatasourceValue_Platform;
}

- (void) addSystemDatasources {
    
    self[TEALDatasourceKey_SystemVersion]      = [[UIDevice currentDevice] systemVersion];
    self[TEALDatasourceKey_LibraryVersion]     = [TEALSystemHelpers collectLibraryVersion];
    self[TEALDatasourceKey_ApplicationName]    = [TEALSystemHelpers applicationName];
}

- (NSDictionary *) queuedFlagWithValue:(BOOL)value {
    
    NSString *displayString = [NSString teal_stringFromBool:value];
    
    return @{ @"was_queued" : displayString };
}


@end
