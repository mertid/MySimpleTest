//
//  TEALDatasourceStore.m
//  TealiumUtilities
//
//  Created by George Webster on 4/8/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

//#import <UIKit/UIDevice.h>
#import "TEALDataSourceStore.h"
#import "TEALDataSourceConstants.h"
#import "NSString+Tealium.h"

static NSString * const TEALMobileDatasourceStorageKey = @"com.tealium.datasourcestore";

static NSString * const TEALDatasourceStoreBaseQueueName = @"com.tealium.datasourcestore.queue";

@interface TEALDataSourceStore ()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) NSMutableDictionary *privateDataSources;

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
        
        NSString *fullQueueName = [NSString stringWithFormat:@"%@.%@", TEALDatasourceStoreBaseQueueName , instanceID];
        const char * queueName = [fullQueueName UTF8String];

        _queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
        _instanceID = instanceID;
        [self unarchiveWithStorageKey:instanceID];
    }
    return self;
}

- (NSMutableDictionary *) dataSources {
    
    if (!self.privateDataSources){
        self.privateDataSources = [NSMutableDictionary new];
    }
    
    return self.privateDataSources;
    
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

- (NSDictionary *) allDataSources {
    
    return self.dataSources;
}

- (void) addDataSources:(NSDictionary *)additionalDataSources {

        [self.dataSources addEntriesFromDictionary:additionalDataSources];
    
        [self archiveWithStorageKey:self.instanceID];
    
}

- (void) removeDataSourceForKey:(NSString *)dataSourceKey {
    
    [self.dataSources removeObjectForKey:dataSourceKey];
    [self archiveWithStorageKey:self.instanceID];
}

- (void) removeAllDataSources {

    [[self dataSources] removeAllObjects];
    
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
