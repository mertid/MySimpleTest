//
//  TEALTestHelpers.m
//  TealiumiOS
//
//  Created by Jason Koo on 12/17/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALTestHelper.h"

@implementation TEALTestHelper

+ (NSArray *) defaultViewDataSourceKeys {
    
    return @[
             TEALDataSourceKey_ApplicationName,
             TEALDataSourceKey_ApplicationRDNS,
             TEALDataSourceKey_ApplicationVersion,
             TEALDataSourceKey_CallType,
             TEALDataSourceKey_ConnectionType,
             TEALDataSourceKey_Device,
             TEALDataSourceKey_DeviceArchitecture,
             TEALDataSourceKey_DeviceBatteryLevel,
             TEALDataSourceKey_DeviceCPUType,
             TEALDataSourceKey_DeviceIsCharging,
             TEALDataSourceKey_DeviceLanguage,
             TEALDataSourceKey_DeviceOrientation,
             TEALDataSourceKey_DeviceOSVersion,
             TEALDataSourceKey_DeviceResolution,
             TEALDataSourceKey_LibraryVersion,
             TEALDataSourceKey_Orientation,
             TEALDataSourceKey_Origin,
             TEALDataSourceKey_SystemVersion,
             TEALDataSourceKey_Pagetype,
             TEALDataSourceKey_Platform,
             TEALDataSourceKey_ViewTitle,
             TEALDataSourceKey_Timestamp,
             TEALDataSourceKey_TimestampLocal,
             TEALDataSourceKey_TimestampOffset,
             TEALDataSourceKey_TimestampUnix,
             TEALDataSourceKey_UUID,
             TEALDataSourceKey_VisitorID
             ];
    
}

+ (NSArray *) defaultEventDataSourceKeys {
    
    return @[
             TEALDataSourceKey_ApplicationName,
             TEALDataSourceKey_ApplicationRDNS,
             TEALDataSourceKey_ApplicationVersion,
             TEALDataSourceKey_CallType,
             TEALDataSourceKey_ConnectionType,
             TEALDataSourceKey_Device,
             TEALDataSourceKey_DeviceArchitecture,
             TEALDataSourceKey_DeviceBatteryLevel,
             TEALDataSourceKey_DeviceCPUType,
             TEALDataSourceKey_DeviceIsCharging,
             TEALDataSourceKey_DeviceLanguage,
             TEALDataSourceKey_DeviceOrientation,
             TEALDataSourceKey_DeviceOSVersion,
             TEALDataSourceKey_DeviceResolution,
             TEALDataSourceKey_LibraryVersion,
             TEALDataSourceKey_Orientation,
             TEALDataSourceKey_Origin,
             TEALDataSourceKey_SystemVersion,
             TEALDataSourceKey_Platform,
             TEALDataSourceKey_EventName,
             TEALDataSourceKey_EventTitle,
             TEALDataSourceKey_Timestamp,
             TEALDataSourceKey_TimestampLocal,
             TEALDataSourceKey_TimestampOffset,
             TEALDataSourceKey_TimestampUnix,
             TEALDataSourceKey_UUID,
             TEALDataSourceKey_VisitorID
             ];
    
}

+ (NSDictionary *) overwriteDataSources {
    
    NSString *value = @"overwriteValue";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_ApplicationName: value,
                                      TEALDataSourceKey_ApplicationRDNS: value,
                                      TEALDataSourceKey_ApplicationVersion: value,
                                      TEALDataSourceKey_CallType: value,
                                      TEALDataSourceKey_Carrier: value,
                                      TEALDataSourceKey_CarrierISO: value,
                                      TEALDataSourceKey_CarrierMCC: value,
                                      TEALDataSourceKey_CarrierMNC: value,
                                      TEALDataSourceKey_ConnectionType: value,
                                      TEALDataSourceKey_Device: value,
                                      TEALDataSourceKey_DeviceArchitecture: value,
                                      TEALDataSourceKey_DeviceBatteryLevel: value,
                                      TEALDataSourceKey_DeviceCPUType: value,
                                      TEALDataSourceKey_DeviceIsCharging: value,
                                      TEALDataSourceKey_DeviceLanguage: value,
                                      TEALDataSourceKey_DeviceOrientation: value,
                                      TEALDataSourceKey_DeviceOSVersion: value,
                                      TEALDataSourceKey_DeviceResolution: value,
                                      TEALDataSourceKey_LibraryVersion: value,
                                      TEALDataSourceKey_EventTitle: value,
                                      TEALDataSourceKey_Orientation: value,
                                      TEALDataSourceKey_Origin: value,
                                      TEALDataSourceKey_SystemVersion: value,
                                      TEALDataSourceKey_EventName: value,
                                      TEALDataSourceKey_Pagetype: value,
                                      TEALDataSourceKey_Platform: value,
                                      TEALDataSourceKey_ViewTitle: value,
                                      TEALDataSourceKey_Timestamp: value,
                                      TEALDataSourceKey_TimestampLocal: value,
                                      TEALDataSourceKey_TimestampOffset: value,
                                      TEALDataSourceKey_TimestampUnix: value,
                                      TEALDataSourceKey_UUID: value,
                                      TEALDataSourceKey_VisitorID: value,
                                      TEALDataSourceKey_WasQueued: value
                                      };
    
    return testDataSources;
    
}

+ (TEALConfiguration *) liveConfig {
    
    return [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                               profile:@"demo"
                                           environment:@"dev"];
}

+ (TEALConfiguration *) nonExistentConfig {
    
    return [TEALConfiguration configurationWithAccount:@"what"
                                               profile:@"who"
                                           environment:@"wow"];
    
}

+ (TEALConfiguration *) configWithOverridePublishSetting:(NSString *)overrideURL {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    config.overridePublishSettingsURL = overrideURL;
    
    return config;
    
}

+ (TEALConfiguration *) configFromTestHTMLFile:(NSString *)filename{
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"html"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL exists = [fileManager fileExistsAtPath:path];
        
    NSAssert(exists, @"Test file %@ does not exist at path:%@", filename, path);
    
    
    // Need a working config, but account-profile doesn't matter as we'll be overriding
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    NSString *localPath = [NSString stringWithFormat:@"file://%@", path];

    config.overridePublishSettingsURL = localPath;
    
    return config;
    
}

+ (TEALConfiguration *) configFromTestJSONFile:(NSString *)filename{
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"json"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL exists = [fileManager fileExistsAtPath:path];
    
    NSAssert(exists, @"Test file %@ does not exist at path:%@", filename, path);
    
    
    // Need a working config, but account-profile doesn't matter as we'll be overriding
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    NSString *localPath = [NSString stringWithFormat:@"file://%@", path];

    [config setOverridePublishSettingsURL:localPath];
        
    return config;
    
}

+ (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!*flag);
    return *flag;
}
@end
