//
//  TEALDeviceDataSources.m
//  Tealium
//
//  Created by Jason Koo on 9/21/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALDeviceDataSources.h"
#import "TEALDataSourceConstants.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <mach/machine.h>

static BOOL deviceIsCharging;
static double deviceBatteryLevel;

@implementation TEALDeviceDataSources

#pragma mark - PUBLIC

+ (NSDictionary *) backgroundDataSources{
    
    // get runtime changable default data
    NSString *architecture = [self architecture];
    NSString *cpuType = [self cpuType];
    NSString *deviceModel = [self devicePlatform];
    NSString *language = [self currentLanguage];

    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    
    // if particular data is not available, skip
    if (architecture)       mDict[TEALDataSourceKey_DeviceArchitecture] = architecture;
    if (cpuType)            mDict[TEALDataSourceKey_DeviceCPUType] = cpuType;
    if (deviceModel)        mDict[TEALDataSourceKey_Device] = deviceModel;
    if (language)           mDict[TEALDataSourceKey_DeviceLanguage] = language;

    
    return [NSDictionary dictionaryWithDictionary:mDict];
}

+ (NSDictionary *) mainThreadDataSources {
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];

    NSString *batteryLevel = [self batteryLevelAsPercentString];
    NSString *batteryIsCharging = [self batteryIsChargingAsString];
    NSString *orientation = [self currentOrientation];
    NSString *resolution = [self resolution];
    
    NSString *systemVersion;
    
#ifndef TEAL_TARGET_WATCHOS
    systemVersion = [[UIDevice currentDevice] systemVersion];
#endif
    
    if (batteryLevel)       mDict[TEALDataSourceKey_DeviceBatteryLevel] = batteryLevel;
    if (batteryIsCharging)  mDict[TEALDataSourceKey_DeviceIsCharging] = batteryIsCharging;
    if (resolution)         mDict[TEALDataSourceKey_DeviceResolution] = resolution;

    if (orientation) {
        
        mDict[TEALDataSourceKey_DeviceOrientation] = orientation;
        
        // DEPRECATE after 5.0
        mDict[TEALDataSourceKey_Orientation] = orientation;
        
    }
    if (systemVersion){
        
        mDict[TEALDataSourceKey_DeviceOSVersion] = systemVersion;
        
        // DEPRECATE after 5.0
        mDict[TEALDataSourceKey_SystemVersion] = systemVersion;
    }
    
    return [NSDictionary dictionaryWithDictionary:mDict];

}

+ (BOOL) isCharging {
    
    return deviceIsCharging;
    
}

+ (double) batteryLevel {

    return deviceBatteryLevel;
    
}

#pragma mark - PRIVATE BACKGROUND SAFE

static NSString *staticDevicePlatform;
+ (NSString *) devicePlatform {
    
    if (!staticDevicePlatform){
        NSString *deviceType;
        struct utsname systemInfo;
        uname(&systemInfo);
        deviceType = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
        staticDevicePlatform = [self prettyPrintPlatformType:deviceType];
    }
    
    return staticDevicePlatform;
}

+ (NSString *) prettyPrintPlatformType:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"AppleTV5,3"])   return @"Apple TV 4";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

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
        staticDeviceCPUType = [NSString stringWithString:cpu];
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


+ (NSString*) currentLanguage{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if(language) return language;
    return nil;
}

#pragma mark - PRIVATE MAIN THREAD ONLY

+ (NSString *) batteryIsChargingAsString {
    
    NSString *string = nil;
    
#ifdef TEAL_TARGET_IOS
    
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) {
        deviceIsCharging = true;
        string = TEALDataSourceValue_True;
    } else {
        deviceIsCharging = false;
        string = TEALDataSourceValue_False;
    }
#endif
    
    return string;
}

+ (NSString *) batteryLevelAsPercentString {
    
    NSString *percentString = TEALDataSourceValue_Unknown;
    
#ifdef TEAL_TARGET_IOS

    if(![UIDevice currentDevice].isBatteryMonitoringEnabled){
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    }
    
    deviceBatteryLevel = [UIDevice currentDevice].batteryLevel * 100;
    
    percentString = [NSString stringWithFormat:@"%.0f", deviceBatteryLevel];
    
#endif
    
    return percentString;

}

+ (NSString*) currentOrientation {
    
    NSString *string = nil;
    
#ifdef TEAL_TARGET_IOS
 
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
    
#endif
    
    return string;
}

//static NSString *deviceModel;
//+ (NSString *) model {
//    if (!deviceModel) {
//        deviceModel = [[[UIDevice currentDevice] model] copy];
//    }
//    return deviceModel;
//}

static NSString *staticDeviceResolution;
+ (NSString *) resolution {
#ifndef TEAL_TARGET_WATCHOS

    if (!staticDeviceResolution){
        CGFloat scale       = [[UIScreen mainScreen] scale];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        CGFloat width       = CGRectGetWidth(screenBounds) * scale;
        CGFloat height      = CGRectGetHeight(screenBounds) * scale;
        
        staticDeviceResolution = [NSString stringWithFormat:@"%.0fx%.0f", width, height];
    }
    return staticDeviceResolution;
#else
    return @"unknown";
#endif
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
