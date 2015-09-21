//
//  TEALDatasources.m
//  Tealium
//
//  Created by Jason Koo on 8/14/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/machine.h>

#import "TEALDataSourceConstants.h"
#import "TEALDataSources.h"
#import "TEALDataSourceStore.h"
#import "TEALSharedDataSources.h"
#import "TEALSystemHelpers.h"

@interface TEALDataSources()

@property (nonatomic, strong) NSString *privateInstanceID;
@property (nonatomic, strong) TEALDataSourceStore *privateStore;
@property (nonatomic, strong) NSDictionary *privateStaticData;
@property (nonatomic, strong) NSDictionary *privateCompileTimeData;
@property (atomic) NSMutableDictionary *privateVolatileDataSources;

@end

@implementation TEALDataSources

#pragma mark - PUBLIC METHODS

+ (NSString *) titleForViewEventWithObject:(NSObject *)obj {
    
    NSString *title = nil;
    NSString *classType = NSStringFromClass([obj class]);
    
    if ([obj respondsToSelector:@selector(title)]) {
        
        title = [obj performSelector:@selector(title)];
        
    }
    
    else if ([obj respondsToSelector:@selector(currentTitle)]) {
        
        title = [obj performSelector:@selector(currentTitle)];
        
    }
    
    else if ([obj respondsToSelector:@selector(possibleTitles)]) {
        
        NSSet *titles = [obj performSelector:@selector(possibleTitles)];
        title = [titles anyObject];
        
    }
    
    else if ([obj respondsToSelector:@selector(restorationIdentifier)]) {
        
        title = [obj performSelector:@selector(restorationIdentifier)];
        
    }
    
    else if ([obj respondsToSelector:@selector(nibName)]) {
        
        title = [obj performSelector:@selector(nibName)];
    }
    
    else {
        title = classType;
    }
    
    return [title copy];
}

+ (NSDictionary *) carrierInfoDataSources {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
    
    Class telephonyNetwork = NSClassFromString(@"CTTelephonyNetworkInfo");
    Class carrier = NSClassFromString(@"CTCarrier");
    if (telephonyNetwork && carrier){
        id netInfo = [[telephonyNetwork alloc]init];
        if (netInfo){
            NSString * carrierName;
            NSString * carrierIso;
            NSString * mobileCountryCode;
            NSString * mobileNetworkCode;
            
            SEL selectorSubscriberCellularProvider = NSSelectorFromString(@"subscriberCellularProvider");
            IMP impSubscriberCellularProvider = [netInfo methodForSelector:selectorSubscriberCellularProvider];
            id (*func)(id, SEL) = (void *)impSubscriberCellularProvider;
            carrier = func(netInfo, selectorSubscriberCellularProvider);
            
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
            
            SEL selectorMNC = NSSelectorFromString(@"mobileCountryCode");
            IMP impMNC = [carrier methodForSelector:selectorMNC];
            NSString * (*funcMNC)(id, SEL) = (void *)impMNC;
            mobileNetworkCode = funcMNC(carrier, selectorMNC);
            
            if (carrierName) mDict[TEALDataSourceKey_Carrier] = carrierName;
            if (carrierIso) mDict[TEALDataSourceKey_CarrierISO] = carrierIso;
            if (mobileCountryCode) mDict[TEALDataSourceKey_CarrierMCC] = mobileCountryCode;
            if (mobileNetworkCode) mDict[TEALDataSourceKey_CarrierMNC] = mobileNetworkCode;
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:mDict];
}

+ (NSDictionary *) deviceInfoDataSources{
    
    // get runtime changable default data
    NSString *architecture = [TEALDataSources architecture];
    NSString *batteryLevel = [TEALDataSources batteryLevelAsPercentString];
    NSString *batteryIsCharging = [TEALDataSources batteryIsChargingAsString];
    NSString *cpuType = [TEALDataSources cpuType];
    NSString *device = [TEALDataSources model];
    //    NSString *hardware = [TEALDataSources hardware];
    NSString *orientation = [TEALDataSources currentOrientation];
    NSString *resolution = [TEALDataSources resolution];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    
    // if particular data is not available, skip
    if (architecture)       mDict[TEALDataSourceKey_DeviceArchitecture] = architecture;
    if (batteryLevel)       mDict[TEALDataSourceKey_DeviceBatteryLevel] = batteryLevel;
    if (batteryIsCharging)  mDict[TEALDataSourceKey_DeviceIsCharging] = batteryIsCharging;
    if (cpuType)            mDict[TEALDataSourceKey_DeviceCPUType] = cpuType;
    if (device)             mDict[TEALDataSourceKey_Device] = device;
    //    if (hardware)              mDict[@"device_model"] = hardware;
    if (orientation)        mDict[TEALDataSourceKey_Orientation] = orientation;
    if (resolution)         mDict[TEALDataSourceKey_DeviceResolution] = resolution;
    if (systemVersion)      mDict[TEALDataSourceKey_SystemVersion] = systemVersion;
    
    return [NSDictionary dictionaryWithDictionary:mDict];
}

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
    
#warning REPLACE with full timestamps data
        
    if (title) {
        switch (eventType) {
            case TEALDispatchTypeEvent:
                datasources[TEALDataSourceKey_EventTitle] = title;
                datasources[TEALDataSourceKey_EventName] = TEALDataSourceValue_EventName;
                break;
            case TEALDispatchTypeView:
                datasources[TEALDataSourceKey_ViewTitle] = title;
                datasources[TEALDataSourceKey_Pagetype] = TEALDataSourceValue_Pagetype;
                break;
            default:
                break;
        }
    }
    
    NSString *dispatchType = [TEALDispatch stringFromDispatchType:eventType];
    if (dispatchType) datasources[TEALDataSourceKey_CallType] = dispatchType;

    datasources[TEALDataSourceKey_Autotracked] = TEALDataSourceValue_False;
    
    return datasources;
}

- (NSMutableDictionary *) volatileDataSources {
    if (!self.privateVolatileDataSources){
        
        self.privateVolatileDataSources = [NSMutableDictionary dictionary];
        
        [self.privateVolatileDataSources addEntriesFromDictionary:[self staticDatasources]];
        [self.privateVolatileDataSources addEntriesFromDictionary:[self compileTimeDataSources]];
        
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

#pragma mark - PRIVATE TRANSMISSION TIME METHODS

- (NSDictionary *) compileTimeDataSources {
    
    if (!self.privateCompileTimeData){

        NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
        
        NSString *appName = [TEALDataSources applicationName];
        
        mDict[TEALDataSourceKey_LibraryVersion] = TEALLibraryVersion;
        if (appName)        mDict[TEALDataSourceKey_ApplicationName] = appName;
        
        self.privateCompileTimeData = [NSDictionary dictionaryWithDictionary:mDict];
    }
    
    return self.privateCompileTimeData;
}

- (NSDictionary *) staticDatasources {
    
    if (!self.privateStaticData){
        self.privateStaticData = @{
                            TEALDataSourceKey_Platform : TEALDataSourceValue_Platform
                            };
    }
    
    return self.privateStaticData;
    
}

- (NSDictionary *) timestampDataSourcesFromDate:(NSDate* ) date {
    
    return nil;
}

#pragma mark - PRIVATE COMPILE TIME HELPERS

+ (NSString *) applicationName {
    
    NSDictionary *bundle = [[NSBundle mainBundle] infoDictionary];
    
    return [bundle objectForKey:@"CFBundleName"];
}

#pragma mark - PRIVATE DEVICE INFO HELPERS

static NSString *staticDeviceCPUType;
+ (NSString *) cpuType {
    if (!staticDeviceCPUType){
        NSMutableString *cpu = [NSMutableString string];
        size_t size;
        cpu_type_t type;
        cpu_subtype_t subtype;
        size = sizeof(type);
        sysctlbyname("hw.cputype", &type, &size, NULL, 0);
        
        size = sizeof(subtype);
        sysctlbyname("hw.cpusubtype", &subtype, &size, NULL, 0);
        
        // values for cputype and cpusubtype defined in mach/machine.h
        if (type == CPU_TYPE_X86) {
            
            [cpu appendString:@"x86 "];
            
        } else if (type == CPU_TYPE_ARM) { // check for subtype ...
            
            [cpu appendString:@"ARM"];
            switch(subtype)
            {
                case CPU_SUBTYPE_ARM_V7:
                    [cpu appendString:@"V7"];
                    break;
                case CPU_SUBTYPE_ARM_V7EM:
                    [cpu appendString:@"V7em"];
                    break;
                case CPU_SUBTYPE_ARM_V7F:
                    [cpu appendString:@"V7f"];
                    break;
                case CPU_SUBTYPE_ARM_V7K:
                    [cpu appendString:@"V7k"];
                    break;
                case CPU_SUBTYPE_ARM_V7M:
                    [cpu appendString:@"V7m"];
                    break;
                case CPU_SUBTYPE_ARM_V7S:
                    [cpu appendString:@"V7s"];
                    break;
                case CPU_SUBTYPE_ARM_V6:
                    [cpu appendString:@"V6"];
                    break;
                case CPU_SUBTYPE_ARM_V6M:
                    [cpu appendString:@"V6m"];
                    break;
                case CPU_SUBTYPE_ARM_V8:
                    [cpu appendString:@"V8"];
                    break;
                case CPU_SUBTYPE_386:
                    [cpu appendString:@"386"];
                    break;
                case CPU_SUBTYPE_486:
                    [cpu appendString:@"486"];
                    break;
                case CPU_SUBTYPE_486SX:
                    [cpu appendString:@"486sx"];
                    break;
                case CPU_SUBTYPE_586:
                    [cpu appendString:@"586"];
                    break;
                    // ...
            }
        }
        staticDeviceCPUType = cpu;
    }
    
    return staticDeviceCPUType;
}

static NSString *staticDeviceArchitecture;
+ (NSString *) architecture {
    
    if (!staticDeviceArchitecture){
        NSString *arch = nil;
        if(sizeof(int*) == 4) {
            arch = @"32";
        } else if(sizeof(int*) == 8) {
            arch = @"64";
        }
        staticDeviceArchitecture = arch;
    }
    return staticDeviceArchitecture;
}

+ (NSString *) batteryIsChargingAsString {
    
    NSString *string = @"false";
    
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) {
        string = @"true";
    }
    
    return string;
}

+ (NSString *) batteryLevelAsPercentString {
    
    float ddFloat = 0.0;
    
    if(![UIDevice currentDevice].isBatteryMonitoringEnabled){
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    ddFloat = [UIDevice currentDevice].batteryLevel * 100;
    
    NSString *percentString = [NSString stringWithFormat:@"%.0f", ddFloat];
    
    if (percentString) {
        return percentString;
    } else {
        return TEALDataSourceValue_Unknown;
    }
}

+ (NSString*) currentOrientation {
    
    NSString *string = nil;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (interfaceOrientation == UIInterfaceOrientationPortrait) string = @"Portrait";
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) string = @"Portrait UpsideDown";
    
    // Interface orientation landscape left and right are opposite of device orientation landscape left and right
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) string = @"Landscape Right";
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) string = @"Landscape Left";
    
    if (string) {
        return string;
    }
    
    // Fallback
    
    UIDevice *device = [UIDevice currentDevice];
    if (device.orientation == UIDeviceOrientationPortrait) string = @"Portrait";
    else if (device.orientation == UIDeviceOrientationLandscapeLeft) string = @"Landscape Left";
    else if (device.orientation == UIDeviceOrientationLandscapeRight)string = @"Landscape Right";
    else if (device.orientation == UIDeviceOrientationPortraitUpsideDown) string = @"Portrait UpsideDown";
    else if (device.orientation == UIDeviceOrientationFaceUp) string = @"Face up";
    else if (device.orientation == UIDeviceOrientationFaceDown) string = @"Face Down";
    
    if (!string) {
        string = TEALDataSourceValue_Unknown;
    }
    
    return string;
}

+ (NSString*) currentLanguage{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if(language) return language;
    return nil;
}

static NSString *deviceModel;
+ (NSString *) model {
    if (!deviceModel) {
        deviceModel = [[UIDevice currentDevice] model];
    }
    return deviceModel;
}

static NSString *staticDeviceResolution;
+ (NSString *) resolution {
    if (!staticDeviceResolution){
        CGFloat scale       = [[UIScreen mainScreen] scale];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        CGFloat width       = CGRectGetWidth(screenBounds) * scale;
        CGFloat height      = CGRectGetHeight(screenBounds) * scale;
        
        staticDeviceResolution = [NSString stringWithFormat:@"%.0fx%.0f", width, height];
    }
    return staticDeviceResolution;
}

//static NSString *staticDeviceHardware;
//+ (NSString *) hardware {
//    if (!staticDeviceHardware){
//        NSString *hardwareName = nil;
//        
//        size_t size;
//        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
//        char *machine = malloc(size);
//        sysctlbyname("hw.machine", machine, &size, NULL, 0);
//        hardwareName = [NSString stringWithUTF8String:machine];
//        free(machine);
//        staticDeviceHardware = hardwareName;
//    }
//    
//    return staticDeviceHardware;
//}






@end
