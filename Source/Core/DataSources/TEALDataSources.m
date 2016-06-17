//
//  TEALDatasources.m
//  Tealium
//
//  Created by Jason Koo on 8/14/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDataSourceConstants.h"
#import "TEALDataSources.h"
#import "TEALDataSourceStore.h"
#import "TEALApplicationDataSources.h"
#import "TEALDeviceDataSources.h"
#import "TEALSharedDataSources.h"
#import "TEALTimestampDataSources.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALVersion.h"

@interface TEALDataSources()

@property (nonatomic, strong) NSString *privateInstanceID;
@property (nonatomic, strong) TEALDataSourceStore *privateStore;
@property (atomic) NSMutableDictionary *privateVolatileDataSources;

@end

@implementation TEALDataSources

#pragma mark - PUBLIC METHODS

+ (double) deviceBatteryLevel {
    
    return [TEALDeviceDataSources batteryLevel];
}

+ (BOOL) deviceIsCharging {
    
    return [TEALDeviceDataSources isCharging];
    
}

- (instancetype) initWithInstanceID:(NSString *) instanceID {
    
    if (!instanceID) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _privateInstanceID = instanceID;
    }
    return self;
}

- (NSDictionary *) mainThreadDataSources {
    
    NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];

    if (!self.disableDeviceInfo) [dataSources addEntriesFromDictionary:[TEALDeviceDataSources mainThreadDataSources]];
    if (!self.disableTimestampInfo) [dataSources addEntriesFromDictionary:[TEALDataSources timestampDataSourcesForDate:[NSDate date]]];

    return [NSDictionary dictionaryWithDictionary:dataSources];
}

- (NSDictionary *) backgroundSafeDataSources {
    
    NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];
    
    if (!self.disableApplicationInfo) [dataSources addEntriesFromDictionary:[TEALApplicationDataSources dataSources]];
    if (!self.disableCarrierInfo) [dataSources addEntriesFromDictionary:[TEALDataSources carrierInfoDataSources]];
    if (!self.disableDeviceInfo) [dataSources addEntriesFromDictionary:[TEALDeviceDataSources backgroundDataSources]];
    if (!self.disableTealiumInfo) [dataSources addEntriesFromDictionary:[TEALDataSources tealiumInfoDataSources]];

    dataSources[TEALDataSourceKey_UUID] = [self uuid];
    dataSources[TEALDataSourceKey_VisitorID] = [self visitorIDCopy];
    
    [dataSources addEntriesFromDictionary:[self persistentDataSources]];

    [dataSources addEntriesFromDictionary:[self clientVolatileDataSources]];
    
    return [NSDictionary dictionaryWithDictionary:dataSources];
}

- (NSDictionary *) fetchQueryStringDataSources {
    
    NSMutableDictionary *mDict = [NSMutableDictionary new];
    
    if (!self.disableDeviceInfo){
        NSDictionary *deviceInfo = [TEALDeviceDataSources mainThreadDataSources];
        NSString *osVersion = deviceInfo[TEALDataSourceKey_DeviceOSVersion];
        if (osVersion) mDict[TEALDataSourceKey_DeviceOSVersion] = osVersion;
    }
    
    if (!self.disableTimestampInfo){
        NSDictionary *timestampInfo = [TEALDataSources timestampDataSourcesForDate:[NSDate date]];
        NSString *unix = timestampInfo[TEALDataSourceKey_TimestampUnix];
        if (unix) mDict[TEALDataSourceKey_TimestampUnix] = unix;
    }
    
    if (!self.disableTealiumInfo){
        NSDictionary *tealiumInfo = [TEALDataSources tealiumInfoDataSources];
        NSString *libraryInfo = tealiumInfo[TEALDataSourceKey_LibraryVersion];
        NSString *platform = tealiumInfo[TEALDataSourceKey_Platform];
        
        if (libraryInfo) mDict[TEALDataSourceKey_LibraryVersion] = libraryInfo;
        if (platform) mDict[TEALDataSourceKey_Platform] = platform;
    }
    
    return [NSDictionary dictionaryWithDictionary:mDict];
    
}

- (NSString *) uuid {
    
    NSString *uuid = [[self instanceStore] allDataSources][TEALDataSourceKey_UUID];
    
    if (!uuid) {
        uuid = [[NSUUID UUID] UUIDString];
        
        [[self instanceStore] addDataSources:@{TEALDataSourceKey_UUID:uuid}];
    }
    
    return uuid;
}

- (NSString *) visitorIDCopy {
    
    NSString *visitorID = [self persistentDataSources][TEALDataSourceKey_VisitorID];
    
    if (!visitorID) {
        
        NSString *uuid = [self uuid];
        
        if (![uuid isKindOfClass:([NSString class])]) {
            return nil;
        }
        
        visitorID = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [[self instanceStore] addDataSources:@{TEALDataSourceKey_VisitorID: visitorID}];
    }
    
    return visitorID;
}

#pragma mark - PRIVATE CLASS
+ (NSDictionary *) carrierInfoDataSources {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    // Framework detetion
    Class telephonyNetwork = NSClassFromString(@"CTTelephonyNetworkInfo");
    Class carrier = NSClassFromString(@"CTCarrier");
    if (!telephonyNetwork && carrier){
        return @{};
    }
    
    id netInfo = [[telephonyNetwork alloc]init];
    if (!netInfo){
        return @{};
    }
    
    // Carrier detection
    SEL selectorSubscriberCellularProvider = NSSelectorFromString(@"subscriberCellularProvider");
    IMP impSubscriberCellularProvider = [netInfo methodForSelector:selectorSubscriberCellularProvider];
    id (*func)(id, SEL) = (void *)impSubscriberCellularProvider;
    carrier = func(netInfo, selectorSubscriberCellularProvider);
    
    if (!carrier){
        return @{};
    }
    
    NSString * carrierName;
    NSString * carrierIso;
    NSString * mobileCountryCode;
    NSString * mobileNetworkCode;
    
    SEL selectorCarrierName = NSSelectorFromString(@"carrierName");
    IMP impCarrierName = [carrier methodForSelector:selectorCarrierName];
    NSString * (*funcCarrierName)(id, SEL) = (void *)impCarrierName; // add arguments after SEL if needed
    carrierName = funcCarrierName(carrier, selectorCarrierName); // add arguments after selectorCarrierName if needed
    
    SEL selectorISO = NSSelectorFromString(@"isoCountryCode");
    IMP impISO = [carrier methodForSelector:selectorISO];
    NSString * (*funcISO)(id, SEL) = (void *)impISO;
    carrierIso = funcISO(carrier, selectorISO);
    
    SEL selectorMCC = NSSelectorFromString(@"mobileCountryCode");
    IMP impMCC = [carrier methodForSelector:selectorMCC];
    NSString * (*funcMCC)(id, SEL) = (void *)impMCC;
    mobileCountryCode = funcMCC(carrier, selectorMCC);
    
    SEL selectorMNC = NSSelectorFromString(@"mobileNetworkCode");
    IMP impMNC = [carrier methodForSelector:selectorMNC];
    NSString * (*funcMNC)(id, SEL) = (void *)impMNC;
    mobileNetworkCode = funcMNC(carrier, selectorMNC);
    
    if (carrierName) mDict[TEALDataSourceKey_Carrier] = carrierName;
    if (carrierIso) mDict[TEALDataSourceKey_CarrierISO] = carrierIso;
    if (mobileCountryCode) mDict[TEALDataSourceKey_CarrierMCC] = mobileCountryCode;
    if (mobileNetworkCode) mDict[TEALDataSourceKey_CarrierMNC] = mobileNetworkCode;

    
    return [NSDictionary dictionaryWithDictionary:mDict];
}

// Hardcoded platform data

static NSDictionary *staticCompileTimeDataSources;
+ (NSDictionary *) tealiumInfoDataSources {
    
    if (!staticCompileTimeDataSources){
        
        NSMutableDictionary *mDict = [NSMutableDictionary new];
        
        mDict[TEALDataSourceKey_LibraryVersion] = TEALLibraryVersion;
        
#ifdef TEAL_TARGET_TVOS
        mDict[TEALDataSourceKey_Platform] = TEALDataSourceValue_TvOS;
        mDict[TEALDataSourceKey_Origin] = TEALDataSourceValue_TV;
#endif
        
#ifdef TEAL_TARGET_IOS
        mDict[TEALDataSourceKey_Platform] = TEALDataSourceValue_IOS;
        mDict[TEALDataSourceKey_Origin] = TEALDataSourceValue_Mobile;
#endif

        staticCompileTimeDataSources = [NSDictionary dictionaryWithDictionary:mDict];
    }
    
    return staticCompileTimeDataSources;
    
}

+ (NSDictionary *) timestampDataSourcesForDate:(id)date {
    
    NSDictionary *data = [TEALTimestampDataSources dataSourcesForDate:date];
    
    return data;
    
}

+ (NSString *) titleForViewEventWithObject:(NSObject *)obj {
    
    NSString *title = nil;
    NSString *classType = NSStringFromClass([obj class]);
    
    if ([obj respondsToSelector:@selector(title)]) {
        
        title = [obj performSelector:@selector(title)];
        
    } else if ([obj respondsToSelector:@selector(currentTitle)]) {
        
        title = [obj performSelector:@selector(currentTitle)];
        
    } else if ([obj respondsToSelector:@selector(possibleTitles)]) {
        
        NSSet *titles = [obj performSelector:@selector(possibleTitles)];
        title = [titles anyObject];
        
    } else if ([obj respondsToSelector:@selector(restorationIdentifier)]) {
        
        title = [obj performSelector:@selector(restorationIdentifier)];
        
    } else if ([obj respondsToSelector:@selector(nibName)]) {
        
        title = [obj performSelector:@selector(nibName)];
    } else {
        title = classType;
    }
    
    return [title copy];
}

+ (NSDictionary *) dispatchDatasourcesForEventType:(TEALDispatchType)eventType
                                             title:(NSString *)title {
    
    NSMutableDictionary *datasources = [NSMutableDictionary new];
        
    switch (eventType) {
        case TEALDispatchTypeEvent:
            if (title) datasources[TEALDataSourceKey_EventTitle] = title;
            datasources[TEALDataSourceKey_EventName] = TEALDataSourceValue_EventName;
            break;
        case TEALDispatchTypeView:
            if (title) datasources[TEALDataSourceKey_ViewTitle] = title;
            datasources[TEALDataSourceKey_Pagetype] = TEALDataSourceValue_Pagetype;
            break;
        default:
            break;
    }
    
    NSString *dispatchType = [TEALDispatch stringFromDispatchType:eventType];
    if (dispatchType) datasources[TEALDataSourceKey_CallType] = dispatchType;
    
    return datasources;
}

#pragma mark - PRIVATE INSTANCE

- (NSMutableDictionary *) clientVolatileDataSources {
    if (!self.privateVolatileDataSources){
        
        self.privateVolatileDataSources = [NSMutableDictionary dictionary];
        
    }
    
    return self.privateVolatileDataSources;
}

- (NSDictionary *) persistentDataSources {
    
    NSDictionary *dataSources = [[self instanceStore] allDataSources];

#warning Something redundant here with UUID method
    
#warning Move the app version info here
    
    // Add UUID here if not already available
    NSString *uuid = dataSources[TEALDataSourceKey_UUID];
    
    if (!uuid){
        
        [[self instanceStore] addDataSources:@{TEALDataSourceKey_UUID : [self uuid]}];
        
        dataSources = [[self instanceStore] allDataSources];
        
    }
    
    return dataSources;
}

- (void) addPersistentDataSources:(NSDictionary *)additionalDataSources {
    
    [[self instanceStore] addDataSources:additionalDataSources];
    
}

- (void) removePersistentDataSourceForKeys:(NSArray *)dataSourceKeys {
    
    NSArray *copy = [dataSourceKeys copy];
    [copy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[self instanceStore] removeDataSourceForKey:obj];
    }];
}

- (void) purgePersistentDataSources {
    
    [[self instanceStore] removeAllDataSources];
    
}

- (TEALDataSourceStore *) instanceStore {
    
    if (!self.privateStore){
        
        self.privateStore = [[TEALDataSourceStore alloc] initWithInstanceID:self.privateInstanceID];

    }
    
    return self.privateStore;
}


@end
