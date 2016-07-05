//
//  TEALSharedDatasources.m
//  Tealium
//
//  Created by Jason Koo on 8/14/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALSharedDataSources.h"

const char * kTEALDatasourceSharedStoreQueueName = "com.tealium.shareddatasources.queue";

@interface TEALSharedDataSources()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableDictionary *datasources;

@end

@implementation TEALSharedDataSources

+ (instancetype) sharedStore {

    static dispatch_once_t onceToken = 0;
    __strong static TEALSharedDataSources *_sharedStore = nil;

    dispatch_once(&onceToken, ^{
        _sharedStore = [[TEALSharedDataSources alloc] initPrivate];
    });

    return _sharedStore;
}

- (instancetype) initPrivate {

    self = [super init];

    if (self) {
        _queue = dispatch_queue_create(kTEALDatasourceSharedStoreQueueName, DISPATCH_QUEUE_CONCURRENT);
        _datasources = [NSMutableDictionary new];
    }
    return self;
}

@end
