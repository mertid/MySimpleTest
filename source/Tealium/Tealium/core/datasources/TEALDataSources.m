//
//  TEALDatasources.m
//  Tealium
//
//  Created by Jason Koo on 8/14/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "NSDate+Tealium.h"
#import "TEALDataSourceConstants.h"
#import "TEALDataSources.h"
#import "TEALDataSourceStore.h"
#import "TEALLogger.h"
#import "TEALSharedDataSources.h"
#import "TEALSystemHelpers.h"

@interface TEALDataSources()

@property (nonatomic, strong) NSString *instanceID;
@property (nonatomic, strong) TEALDataSourceStore *store;
@property (nonatomic, strong) NSDictionary *staticData;
@property (nonatomic, strong) NSDictionary *compileTimeData;

@end

@implementation TEALDataSources

#pragma mark - PUBLIC METHODS

- (instancetype) initWithInstanceID:(NSString *) instanceID {
    
    if (!instanceID) {
        TEAL_LogNormal(@"DatasourceStore initialization attempted without an instance ID.");
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _instanceID = instanceID;
        _store = [[TEALDataSourceStore alloc] initWithInstanceID:instanceID];
    }
    return self;
}

- (NSDictionary *) transmissionTimeDatasourcesForEventType:(TEALDispatchType)eventType {
    
    NSMutableDictionary *datasources = [NSMutableDictionary new];
    
    [datasources addEntriesFromDictionary:[self staticDatasources]];
    [datasources addEntriesFromDictionary:[self compileTimeDataSources]];

    switch (eventType) {
        case TEALDispatchTypeEvent:
            datasources[TEALDataSourceKey_EventName] = TEALDataSourceValue_EventName;
            break;
        case TEALDispatchTypeView:
            datasources[TEALDataSourceKey_Pagetype] = TEALDataSourceValue_Pagetype;
            break;
        default:
            break;
    }
    
    NSString *dispatchType = [TEALDispatch stringFromDispatchType:eventType];
    
    if (dispatchType) datasources[TEALDataSourceKey_CallType] = dispatchType;
    
    return datasources;
}

- (NSDictionary *) captureTimeDatasourcesForEventType:(TEALDispatchType)eventType title:(NSString *)title {
    
    NSMutableDictionary *datasources = [NSMutableDictionary new];
    
#warning REPLACE with full timestamps data
    datasources[TEALDataSourceKey_Timestamp] = [[NSDate date] teal_timestampISOStringValue];
    
    if (title) {
        switch (eventType) {
            case TEALDispatchTypeEvent:
                datasources[TEALDataSourceKey_EventTitle] = title;
                break;
            case TEALDispatchTypeView:
                datasources[TEALDataSourceKey_ViewTitle] = title;
                break;
            default:
                break;
        }
    }
    
    datasources[TEALDataSourceKey_Autotracked] = TEALDataSourceValue_False;
    
    return datasources;
}

#pragma mark - PUBLIC HELPERS

- (NSString *) applicationUUID {
    
    NSString *applicationUUID = self.store.dataSourcesCopy[TEALDataSourceKey_UUID];
    
    if (!applicationUUID) {
        applicationUUID = [[NSUUID UUID] UUIDString];
        
        [self.store addDataSources:@{TEALDataSourceKey_UUID:applicationUUID}];
    }
    
    return applicationUUID;
}

- (NSString *) visitorIDCopy {
    
    NSString *visitorID = [self persistentDataSources][TEALDataSourceKey_VisitorID];
    
    if (!visitorID) {

        NSString *uuid = [self applicationUUID];
        
        if (![uuid isKindOfClass:([NSString class])]) {
            return nil;
        }
        
        visitorID = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [self.store addDataSources:@{TEALDataSourceKey_VisitorID: visitorID}];
    }
    
    return visitorID;
}

- (NSDictionary *) persistentDataSources {
    
    NSDictionary *copy = [self.store dataSourcesCopy];
    if (!copy){
        copy = @{};
    }
    return copy;
}

- (void) setPersistentDataSources:(NSDictionary *)newDataSources {
    [self.store setNewDataSources:newDataSources];
}

#pragma mark - PRIVATE METHODS

- (TEALDataSourceStore *) instanceStore {
    return self.store;
}


#pragma mark - PRIVATE TRANSMISSION TIME METHODS

- (NSDictionary *) compileTimeDataSources {
    
    if (!self.compileTimeData){

        NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
        
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        NSString *appName = [TEALSystemHelpers applicationName];
        
        mDict[TEALDataSourceKey_LibraryVersion] = TEALLibraryVersion;
        if (appName)        mDict[TEALDataSourceKey_ApplicationName] = appName;
        if (systemVersion)  mDict[TEALDataSourceKey_SystemVersion] = systemVersion;
        
        self.compileTimeData = [NSDictionary dictionaryWithDictionary:mDict];
    }
    
    return self.compileTimeData;
}

- (NSDictionary *) staticDatasources {
    
    if (!self.staticData){
        self.staticData = @{
                            TEALDataSourceKey_Platform : TEALDataSourceValue_Platform
                            };
    }
    
    return self.staticData;
    
}

- (NSDictionary *) timestampDataSourcesFromDate:(NSDate* ) date {
    
    return nil;
}

#pragma mark - PRIVATE CAPTURE TIME METHODS

- (NSDictionary *) dynamicDeviceDataSources {
    
    // get runtime changable default data
    NSString *batteryLevel = [TEALDataSources batteryLevelAsPercentString];
    NSString *batteryIsCharging = [TEALDataSources batteryIsChargingAsString];
    NSString *device = [[UIDevice currentDevice] model];
    NSString *orientation = [TEALDataSources currentOrientation];
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    
    // if particular data is not available, skip
    if (batteryLevel)                       mDict[TEALDataSourceKey_DeviceBatteryLevel] = batteryLevel;
    if (batteryIsCharging)                  mDict[TEALDataSourceKey_DeviceIsCharging] = batteryIsCharging;
    if (device)                             mDict[TEALDataSourceKey_Device] = device;
    if (orientation)                        mDict[TEALDataSourceKey_Orientation] = orientation;
    
    return [NSDictionary dictionaryWithDictionary:mDict];
}


#pragma mark - PRIVATE CAPTURE TIME HELPERS

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

#pragma mark - PRIVATE TRANSMISSION TIME HELPERS

+ (NSString*) currentLanguage{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if(language) return language;
    return nil;
}

+ (NSString*) localGMTOffset{
    // return hours offset
    int offset = (int)([[NSTimeZone localTimeZone] secondsFromGMT] / 3600);
    return [NSString stringWithFormat:@"%i", offset];
}

+ (NSString*) timestampAsISOLocalFrom:(NSDate*) date{
    // modified from original by Radu Poenaru
    NSDateFormatter *_sISO8601Local = nil;
    if (!_sISO8601Local) {
        _sISO8601Local = [[NSDateFormatter alloc] init];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyy-MM-dd'T'HH:mm:ss"];
        [_sISO8601Local setTimeStyle:NSDateFormatterFullStyle];
        [_sISO8601Local setDateFormat:strFormat];
    }
    if (date) return[_sISO8601Local stringFromDate:date];
    return nil;
}

+ (NSString*) timestampAsISOFrom:(NSDate*)date{
    // modified from original by Radu Poenaru
    NSDateFormatter *_sISO8601 = nil;
    
    if (!_sISO8601) {
        _sISO8601 = [[NSDateFormatter alloc] init];
        
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_sISO8601 setTimeZone:timeZone];
        
        NSMutableString *strFormat = [NSMutableString stringWithString:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        [_sISO8601 setTimeStyle:NSDateFormatterFullStyle];
        [_sISO8601 setDateFormat:strFormat];
    }
    if (date) return[_sISO8601 stringFromDate:date];
    return nil;
}


@end
