//
//  TEALLifecycleStore.m
//  Tealium
//
//  Created by Jason Koo on 8/22/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycleStore.h"
#import "TEALError.h"

const char * kTEALLifecycleStoreQueueName = "com.tealium.lifecyclestore.queue";

@interface TEALLifecycleStore()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableDictionary *lifecycleEvents;
@property (nonatomic, strong) NSString *privateInstanceID;

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
        _lifecycleEvents = [NSMutableDictionary new];
        _privateInstanceID = instanceID;
    }
    return self;
}

- (void) loadAllData {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *allEvents = [defaults objectForKey:[self storageKey]];
    [self.lifecycleEvents addEntriesFromDictionary:allEvents];

}

//- (NSDictionary *) loadDataForKey:(NSString *)key {
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *allEvents = [defaults objectForKey:[self storageKey]];
//    NSDictionary *keyEvents = allEvents[key];
//    
//    if (![keyEvents isKindOfClass:[NSDictionary class]]){
//        return @{};
//    }
//    
//    [self.lifecycleEvents addEntriesFromDictionary:@{key:keyEvents}];
//    return self.lifecycleEvents[key];
//    
//}

- (void) saveData:(NSDictionary *)data forKey:(NSString *)key completion:(TEALBooleanCompletionBlock)completion{
    
//    dispatch_barrier_async(self.queue, ^{
    
    if (!data){
        return;
    }
    
#warning Save seconds awake here if sleep?
    
    self.lifecycleEvents[key] = data;
    
    [self archiveWithStorageKey:[self storageKey] completion:completion];
    
//    });
}

- (id) objectForKey:(id<NSCopying, NSSecureCoding>)key {
    
    __block id obj = nil;
    
    dispatch_sync(self.queue, ^{
        obj = self.lifecycleEvents[key];
    });
    
    return obj;
}

- (id) objectForKeyedSubscript:(id <NSCopying, NSSecureCoding>)key {
    return [self objectForKey:key];
}

- (void) setObject:(id<NSCopying, NSSecureCoding>)object
            forKey:(id<NSCopying, NSSecureCoding>)aKey {
    
//    dispatch_barrier_async(self.queue, ^{
    
        self.lifecycleEvents[aKey] = object;
        [self archiveWithStorageKey:[self storageKey] completion:nil];
        
//    });
}

- (void) setObject:(id)obj forKeyedSubscript:(id <NSCopying, NSSecureCoding>)key {
    [self setObject:obj
             forKey:key];
}

#pragma mark - I/O

- (NSString *) storageKey {
    
    return [NSString stringWithFormat:@"com.tealium.lifecyclestore.%@", self.privateInstanceID];
    
}

- (BOOL) unarchiveWithStorageKey:(NSString *)key {
    
    __block BOOL unarchived = NO;
    
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        
        dispatch_barrier_sync(self.queue, ^{
            
            [self.lifecycleEvents addEntriesFromDictionary:obj];
            
            unarchived = YES;
            
        });
        
    }
    return unarchived;
}

- (void) archiveWithStorageKey:(NSString *)key completion:(TEALBooleanCompletionBlock)completion {
    
    BOOL success = NO;
    __block NSDictionary *dataCopy = nil;
    NSError *error = nil;
    
    
    dispatch_barrier_sync(self.queue, ^{
        dataCopy = [self.lifecycleEvents copy];
    });
    
    if (dataCopy) {
        [[NSUserDefaults standardUserDefaults] setObject:dataCopy
                                                  forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        success = YES;
        
    } else {
        error = [TEALError errorWithCode:400
                             description:@"Problem saving lifecycle data."
                                  reason:@"Data for lifecycle event missing."
                              suggestion:@"Consult Tealium mobile Engineer - LifecycleStore line 143"];
        
    }
    
    if (completion) completion(success, error);
}

#pragma mark - PRIVATE INSTANCE METHODS

- (instancetype) init {
    [NSException raise:@"Should not be initialized directly"
                format:@"Please use initWithInstanceID method."];
    return nil;
}


@end
