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
#import "TEALSystemHelpers.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALVersion.h"

@interface TEALDataSources()

@property (nonatomic, strong) NSString *privateInstanceID;
@property (nonatomic, strong) TEALDataSourceStore *privateStore;
@property (atomic) NSMutableDictionary *privateVolatileDataSources;

@end

@implementation TEALDataSources

#pragma mark - PUBLIC METHODS

- (instancetype) initWithInstanceID:(NSString *) instanceID {
    
    if (!instanceID) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _privateInstanceID = instanceID;
        _privateStore = [[TEALDataSourceStore alloc] initWithInstanceID:_privateInstanceID];
    }
    return self;
}

+ (NSDictionary *) applicationInfoDataSources {
    
    return [[TEALApplicationDataSources dataSources] copy];
    
}

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

+ (NSDictionary *) deviceInfoDataSources{
    
    NSDictionary *deviceInfo =
    [TEALSystemHelpers compositeDictionaries:
     @[
       [TEALDeviceDataSources mainThreadDataSources],
       [TEALDeviceDataSources backgroundDataSources]
       ]];
    return deviceInfo;
    
}

static NSDictionary *staticCompileTimeDataSources;
+ (NSDictionary *) tealiumInfoDataSources {
    
    if (!staticCompileTimeDataSources){
        
        NSMutableDictionary *mDict = [NSMutableDictionary new];
        
        mDict[TEALDataSourceKey_LibraryVersion] = TEALLibraryVersion;
        
#ifdef TARGET_TEAL_TVOS
        mDict[TEALDataSourceKey_Platform] = @"tvOS";
#endif
#ifdef TARGET_TEAL_IOS
        mDict[TEALDataSourceKey_Platform] = @"iOS";
#endif
        mDict[TEALDataSourceKey_Origin] = TEALDataSourceValue_Origin;

        staticCompileTimeDataSources = [NSDictionary dictionaryWithDictionary:mDict];
    }
    
    return staticCompileTimeDataSources;
    
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

//- (NSDictionary *) transmissionTimeDatasourcesForEventType:(TEALDispatchType)eventType {
//    
//    NSMutableDictionary *datasources = [NSMutableDictionary new];
//    
//    [datasources addEntriesFromDictionary:[self staticDatasources]];
//    [datasources addEntriesFromDictionary:[self compileTimeDataSources]];
//
//    switch (eventType) {
//        case TEALDispatchTypeEvent:
//            datasources[TEALDataSourceKey_EventName] = TEALDataSourceValue_EventName;
//            break;
//        case TEALDispatchTypeView:
//            datasources[TEALDataSourceKey_Pagetype] = TEALDataSourceValue_Pagetype;
//            break;
//        default:
//            break;
//    }
//    
//    NSString *dispatchType = [TEALDispatch stringFromDispatchType:eventType];
//    
//    if (dispatchType) datasources[TEALDataSourceKey_CallType] = dispatchType;
//    
//    return datasources;
//}

- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALDispatchType)eventType title:(NSString *)title {
    
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

    // TODO: 5.1
//    datasources[TEALDataSourceKey_Autotracked] = TEALDataSourceValue_False;
    
    return datasources;
}

- (NSMutableDictionary *) clientVolatileDataSources {
    if (!self.privateVolatileDataSources){
        
        self.privateVolatileDataSources = [NSMutableDictionary dictionary];
        
    }
    
    return self.privateVolatileDataSources;
}

- (NSDictionary *) persistentDataSourcesCopy {
    
    NSDictionary *copy = [self.privateStore dataSourcesCopy];
    if (!copy){
        copy = @{};
    }
    return copy;
}

- (void) addPersistentDataSources:(NSDictionary *)additionalDataSources {
    
    [self.privateStore addDataSources:additionalDataSources];
    
}

- (void) removePersistentDataSourceForKeys:(NSArray *)dataSourceKeys {
    
    NSArray *copy = [dataSourceKeys copy];
    [copy enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.privateStore removeDataSourceForKey:obj];
    }];
}

#pragma mark - PUBLIC HELPERS

+ (double) deviceBatteryLevel {
    
    return [TEALDeviceDataSources batteryLevel];
}

+ (BOOL) deviceIsCharging {
    
    return [TEALDeviceDataSources isCharging];
    
}

- (NSString *) applicationUUID {
    
    NSString *applicationUUID = self.privateStore.dataSourcesCopy[TEALDataSourceKey_UUID];
    
    if (!applicationUUID) {
        applicationUUID = [[NSUUID UUID] UUIDString];
        
        [self.privateStore addDataSources:@{TEALDataSourceKey_UUID:applicationUUID}];
    }
    
    return applicationUUID;
}

- (NSString *) visitorIDCopy {
    
    NSString *visitorID = [self persistentDataSourcesCopy][TEALDataSourceKey_VisitorID];
    
    if (!visitorID) {

        NSString *uuid = [self applicationUUID];
        
        if (![uuid isKindOfClass:([NSString class])]) {
            return nil;
        }
        
        visitorID = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [self.privateStore addDataSources:@{TEALDataSourceKey_VisitorID: visitorID}];
    }
    
    return visitorID;
}

#pragma mark - PRIVATE METHODS

- (TEALDataSourceStore *) instanceStore {
    return self.privateStore;
}


@end
