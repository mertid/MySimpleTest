//
//  TEALDatasources.m
//  Tealium
//
//  Created by Jason Koo on 8/14/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "NSDate+Tealium.h"
#import "TEALDatasources.h"
#import "TEALDatasourceConstants.h"
#import "TEALDatasourceStore.h"
#import "TEALLogger.h"
#import "TEALSharedDatasources.h"

const char * kTEALDatasourcesQueueName = "com.tealium.datasources.queue";

@interface TEALDatasources()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableDictionary *datasources;
@property (nonatomic, strong) NSString *instanceID;
@property (nonatomic, strong) TEALDatasourceStore *store;


@end

@implementation TEALDatasources

#pragma mark - PUBLIC METHODS

- (instancetype) initWithInstanceID:(NSString *) instanceID {
    
    if (!instanceID) {
        TEAL_LogNormal(@"DatasourceStore initialization attempted without an instance ID.");
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _queue = dispatch_queue_create(kTEALDatasourcesQueueName, DISPATCH_QUEUE_CONCURRENT);
        _datasources = [NSMutableDictionary new];
        _instanceID = instanceID;
        _store = [[TEALDatasourceStore alloc] initWithInstanceID:instanceID];
        
//        [self unarchiveWithStorageKey:instanceID];
    }
    return self;
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

#warning Rename to mainThread something...

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

#pragma mark - PUBLIC HELPERS

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

- (NSDictionary *) dataSourcesCopy {
    return [self.store dataSourcesCopy];
}

- (void) setDataSources:(NSDictionary *)newDataSources {
    [self.store setDataSources:newDataSources];
}

@end
