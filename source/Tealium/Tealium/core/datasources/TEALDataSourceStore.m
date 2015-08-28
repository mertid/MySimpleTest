//
//  TEALDatasourceStore.m
//  TealiumUtilities
//
//  Created by George Webster on 4/8/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIDevice.h>
#import "TEALDataSourceStore.h"
#import "TEALDataSourceConstants.h"
#import "TEALDispatch.h"
#import "TEALSystemHelpers.h"
#import "NSDate+Tealium.h"
#import "NSString+Tealium.h"
#import "TEALLogger.h"


static NSString * const kTEALMobileDatasourceStorageKey = @"com.tealium.datasourcestore";
const char * kTEALDatasourceStoreQueueName = "com.tealium.datasourcestore.queue";

@interface TEALDataSourceStore ()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) NSMutableDictionary *dataSources;

@property (nonatomic, strong) NSString *instanceID;

@end

@implementation TEALDataSourceStore

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString *) instanceID {
    
    if (!instanceID) {
        TEAL_LogNormal(@"DatasourceStore initialization attempted without an instance ID.");
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _queue = dispatch_queue_create(kTEALDatasourceStoreQueueName, DISPATCH_QUEUE_CONCURRENT);
        _dataSources = [NSMutableDictionary new];
        _instanceID = instanceID;
        [self unarchiveWithStorageKey:instanceID];
    }
    return self;
}

- (id) objectForKey:(id<NSCopying, NSSecureCoding>)key {
    
    __block id obj = nil;
    
    dispatch_sync(self.queue, ^{
        obj = self.dataSources[key];
    });
    
    return obj;
}

- (id) objectForKeyedSubscript:(id <NSCopying, NSSecureCoding>)key {
    return [self objectForKey:key];
}

- (void) setObject:(id<NSCopying, NSSecureCoding>)object
            forKey:(id<NSCopying, NSSecureCoding>)aKey {
    
    dispatch_barrier_async(self.queue, ^{
        
        self.dataSources[aKey] = object;
    });
}

- (void) setObject:(id)obj forKeyedSubscript:(id <NSCopying, NSSecureCoding>)key {
    [self setObject:obj
             forKey:key];
}

- (NSDictionary *) dataSourcesCopy {
    return [self.dataSources copy];
}

- (void) setNewDataSources:(NSDictionary *)newDataSources {
//    dispatch_barrier_sync(self.queue, ^{
        [self.dataSources removeAllObjects];
        [self.dataSources addEntriesFromDictionary:newDataSources];
        [self archiveWithStorageKey:self.instanceID];
//    });
}

- (void) addDataSources:(NSDictionary *)additionalDataSources {
//    dispatch_barrier_sync(self.queue, ^{
        [self.dataSources addEntriesFromDictionary:additionalDataSources];
        [self archiveWithStorageKey:self.instanceID];
//    });
    
}

#pragma mark - I/O

- (BOOL) unarchiveWithStorageKey:(NSString *)key {
    
    __block BOOL unarchived = NO;
    
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        dispatch_barrier_sync(self.queue, ^{
            [self.dataSources addEntriesFromDictionary:obj];
            unarchived = YES;
        });
    }
    return unarchived;
}

- (void) archiveWithStorageKey:(NSString *)key {
    
    __block NSDictionary *dataCopy = nil;
    
    dispatch_barrier_sync(self.queue, ^{
        dataCopy = [self.dataSources copy];
    });
    
    if (dataCopy) {
        [[NSUserDefaults standardUserDefaults] setObject:dataCopy
                                                  forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSDictionary *) systemInfoDatasources {
    
    NSMutableDictionary *dataSources = [self dataSourcesForKeys:@[TEALDataSourceKey_Platform,
                                                                  TEALDataSourceKey_SystemVersion,
                                                                  TEALDataSourceKey_LibraryVersion]];
    
    dataSources[TEALDataSourceKey_Timestamp] = [[NSDate date] teal_timestampISOStringValue];
    
    return dataSources;
}

- (NSMutableDictionary *) dataSourcesForKeys:(NSArray *)keys {
    
    NSMutableDictionary *dataSources = [NSMutableDictionary new];
    
    for (id key in keys) {
        
        id obj = self[key];
        
        if (obj) {
            dataSources[key] = obj;
        }
    }
    return dataSources;
}


#pragma mark - PRIVATE INSTANCE METHODS

- (instancetype) init {
    [NSException raise:@"Should not be initialized directly"
                format:@"Please use initWithInstanceID method."];
    return nil;
}

//- (void) addStaticDatasource {
//    
//    self[TEALDataSourceKey_EventName]   = TEALDataSourceValue_EventName;
//    self[TEALDataSourceKey_Pagetype]    = TEALDataSourceValue_Pagetype;
//    self[TEALDataSourceKey_Platform]    = TEALDataSourceValue_Platform;
//}

//- (void) addSystemDataSources {
//    
//    self[TEALDataSourceKey_SystemVersion]      = [[UIDevice currentDevice] systemVersion];
//    self[TEALDataSourceKey_LibraryVersion]     = TEALLibraryVersion;
//    self[TEALDataSourceKey_ApplicationName]    = [TEALSystemHelpers applicationName];
//}

- (NSDictionary *) queuedFlagWithValue:(BOOL)value {
    
    NSString *displayString = [NSString teal_stringFromBool:value];
    
    return @{ @"was_queued" : displayString };
}


@end
