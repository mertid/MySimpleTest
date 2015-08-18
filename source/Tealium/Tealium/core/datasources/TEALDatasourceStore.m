//
//  TEALDatasourceStore.m
//  TealiumUtilities
//
//  Created by George Webster on 4/8/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIDevice.h>
#import "TEALDatasourceStore.h"
#import "TEALDatasourceConstants.h"
#import "TEALDispatch.h"
#import "TEALSystemHelpers.h"
#import "NSDate+Tealium.h"
#import "NSString+Tealium.h"
#import "TEALLogger.h"


static NSString * const kTEALMobileDatasourceStorageKey = @"com.tealium.datasourcestore";

@interface TEALDatasourceStore ()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) NSMutableDictionary *datasources;

@property (nonatomic, strong) NSString *instanceID;

@end

@implementation TEALDatasourceStore

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString *) instanceID {
    
    if (!instanceID) {
        TEAL_LogNormal(@"DatasourceStore initialization attempted without an instance ID.");
        return nil;
    }
    
    self = [super init];
    
    if (self) {
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

- (NSDictionary *) dataSourcesCopy {
    return [self.datasources copy];
}

- (void) setDataSources:(NSDictionary *)newDataSources {
    dispatch_barrier_sync(self.queue, ^{
        [self.datasources removeAllObjects];
        [self.datasources addEntriesFromDictionary:newDataSources];
        [self archiveWithStorageKey:self.instanceID];
    });
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
