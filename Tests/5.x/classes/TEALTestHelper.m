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
    
//    config.overridePublishSettingsURL = path;
    
    return config;
    
}

@end
