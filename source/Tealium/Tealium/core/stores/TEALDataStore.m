//
//  TEALDataStore.m
//  Tealium
//
//  Created by Jason Koo on 9/28/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALDataStore.h"

static NSString * const TEALBaseKeyDataStore = @"com.tealium.datastore";

@interface TEALDataStore()

@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSString *instanceID;
@property (nonatomic, strong) NSString *storageKey;

@end

@implementation TEALDataStore

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString *) instanceID {
    
    if (!instanceID) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {

        NSString *fullQueueName = [NSString stringWithFormat:@"%@.queue.%@", TEALBaseKeyDataStore, instanceID];
        
        const char * queueName = [fullQueueName UTF8String];
        
        _queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
        _data = [NSMutableDictionary new];
        _instanceID = instanceID;
        _storageKey = [NSString stringWithFormat:@"%@.storagekey.%@", TEALBaseKeyDataStore, instanceID];
        
        [self unarchiveWithStorageKey:_storageKey];
    }
    return self;
}

- (id) objectForKey:(id<NSCopying, NSSecureCoding>)key {
    
    __block id obj = nil;
    
    dispatch_sync(self.queue, ^{
        obj = self.data[key];
    });
    
    return obj;
}

- (id) objectForKeyedSubscript:(id <NSCopying, NSSecureCoding>)key {
    return [self objectForKey:key];
}

- (void) setObject:(id<NSCopying, NSSecureCoding>)object
            forKey:(id<NSCopying, NSSecureCoding>)aKey {
    
    dispatch_barrier_async(self.queue, ^{
        
        self.data[aKey] = object;
        [self archiveWithStorageKey:self.storageKey];
        
    });
}

- (void) setObject:(id)obj forKeyedSubscript:(id <NSCopying, NSSecureCoding>)key {
    [self setObject:obj
             forKey:key];
}

- (void) removeObjectForKey:(id<NSCopying, NSSecureCoding>)key {
    
    dispatch_sync(self.queue, ^{
        [self.data removeObjectForKey:key];
        [self archiveWithStorageKey:self.storageKey];
    });
}

- (void) addEntriesFromDictionary:(NSDictionary *)dictionary {
    
    NSDictionary *dictionaryCopy = [dictionary copy];
    
    [dictionaryCopy enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self setObject:obj forKey:key];
    }];
    
}

#pragma mark - PRIVATE LIFECYCLE

- (instancetype) init {
    [NSException raise:@"Should not be initialized directly"
                format:@"Please use initWithInstanceID method."];
    return nil;
}

#pragma mark - PRIVATE I/O

- (BOOL) unarchiveWithStorageKey:(NSString *)key {
    
    __block BOOL unarchived = NO;
    
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        dispatch_barrier_sync(self.queue, ^{
            [self.data addEntriesFromDictionary:obj];
            unarchived = YES;
        });
    }
    return unarchived;
}

- (void) archiveWithStorageKey:(NSString *)key {
    
    __block NSDictionary *dataCopy = nil;
    
    dispatch_barrier_sync(self.queue, ^{
        dataCopy = [self.data copy];
    });
    
    if (dataCopy) {
        [[NSUserDefaults standardUserDefaults] setObject:dataCopy
                                                  forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
