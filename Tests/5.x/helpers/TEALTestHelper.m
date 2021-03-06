//
//  TEALTestHelpers.m
//  TealiumiOS
//
//  Created by Jason Koo on 12/17/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALTestHelper.h"
#import "TEALError.h"

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
             TEALDataSourceKey_Tealium_Library_Name,
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
             TEALDataSourceKey_Tealium_Library_Name,
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
                                      TEALDataSourceKey_Tealium_Library_Name: value,
                                      TEALDataSourceKey_EventTitle: value,
                                      TEALDataSourceKey_Orientation: value,
                                      TEALDataSourceKey_Origin: value,
                                      TEALDataSourceKey_SystemVersion: value,
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

+ (NSDictionary *) dictionaryFromJSONFile:(NSString *)filename {
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:@"json"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL exists = [fileManager fileExistsAtPath:path];
    
    NSAssert(exists, @"Test file %@ does not exist at path:%@", filename, path);
    
    NSData *data = [fileManager contentsAtPath:path];
    
    NSDictionary *resultDictionary = nil;
    NSError *error;
    
    resultDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingAllowFragments
                                                         error:&error];
    
    return resultDictionary;
    
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



+ (BOOL)doesDictionary :(NSDictionary *)sourceDict containDictionaryKeys:(NSDictionary *)targetDict error:(NSError *__autoreleasing *)error{
   
    BOOL doesContain = true;
    
    for(id key in targetDict) {
        
        if (![sourceDict objectForKey:key]) {
            *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                                 description:[NSString stringWithFormat:@"Dictionaries did not match at key: %@ ", key]
                                      reason:@"No value for target dictionary key in source dictionary"
                                  suggestion:@"Check spelling"];
            return NO;
        }
    }

    return doesContain;
}

+ (BOOL)doesDictionary:(NSDictionary *)sourceDict containsDictionary:(NSDictionary *)targetDict error:(NSError *__autoreleasing *)error {
    
    BOOL doesContain = true;
    
    for(id key in targetDict) {
        
        if (![sourceDict objectForKey:key]) {
            *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                                  description:[NSString stringWithFormat:@"Dictionaries did not match at key: %@ ", key]
                                       reason:@"No value for target dictionary key in source dictionary"
                                   suggestion:@"Check spelling"];
            
            return NO;
            
        }else {
            
            id valueForDictA = [targetDict objectForKey:key];
            id valueForContaining = [sourceDict objectForKey:key];
            
            BOOL valuesAreEqual = [self valuesEqual:valueForDictA and:valueForContaining];
            
            if (!valuesAreEqual){
                *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                                      description:[NSString stringWithFormat:@"Dictionaries did not match at values: %@ and %@ ", valueForDictA, valueForContaining]
                                           reason:@"Issue with dictionary value"
                                       suggestion:@"Check spelling and data types"];
                
                return NO;
            }
        }
    }
    
    return doesContain;
}


+ (BOOL)valuesEqual: (id)firstObject and:(id)secondObject{
    
    BOOL isValuesEqual = false;
    
    if ([firstObject isKindOfClass:[NSString class]] &&
        [secondObject isKindOfClass:[NSString class]]){
        if ([firstObject isEqualToString: secondObject]){
            isValuesEqual = true;
        }
    } else if([firstObject isKindOfClass:[NSNumber class]] &&
              [secondObject isKindOfClass:[NSNumber class]]) {
        if ([firstObject isEqualToNumber:secondObject]){
            isValuesEqual = true;
            
        }
        
    }else {
        if (firstObject == secondObject){
            isValuesEqual = true;
        
        }
    }
    
    return isValuesEqual;

}

@end
