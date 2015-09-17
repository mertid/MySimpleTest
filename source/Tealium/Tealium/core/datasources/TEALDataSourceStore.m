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
#import "NSString+Tealium.h"

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

- (void) addDataSources:(NSDictionary *)additionalDataSources {

        [self.dataSources addEntriesFromDictionary:additionalDataSources];
        [self archiveWithStorageKey:self.instanceID];
    
}

- (void) removeDataSourceForKey:(NSString *)dataSourceKey {
    
    [self.dataSources removeObjectForKey:dataSourceKey];
    [self archiveWithStorageKey:self.instanceID];
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

//- (NSDictionary *) queuedFlagWithValue:(BOOL)value {
//    
//    NSString *displayString = [NSString teal_stringFromBool:value];
//    
//    return @{ @"was_queued" : displayString };
//}


@end
