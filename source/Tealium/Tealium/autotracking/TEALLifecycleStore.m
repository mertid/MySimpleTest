//
//  TEALLifecycleStore.m
//  Tealium
//
//  Created by Jason Koo on 8/22/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycleStore.h"

const char * kTEALLifecycleStoreQueueName = "com.tealium.lifecyclestore.queue";

@interface TEALLifecycleStore()

@property (nonatomic, strong) dispatch_queue_t queue;

@property (nonatomic, strong) NSMutableDictionary *dataSources;

@property (nonatomic, strong) NSString *instanceID;

@end

@implementation TEALLifecycleStore

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString *) instanceID {
    
    if (!instanceID) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _queue = dispatch_queue_create(kTEALLifecycleStoreQueueName, DISPATCH_QUEUE_CONCURRENT);
        _dataSources = [NSMutableDictionary new];
        _instanceID = instanceID;
        
#warning update to use a class method that returns a unique lifecycle store instance id rather than just instance id
        
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

#pragma mark - PRIVATE INSTANCE METHODS

- (instancetype) init {
    [NSException raise:@"Should not be initialized directly"
                format:@"Please use initWithInstanceID method."];
    return nil;
}


@end
