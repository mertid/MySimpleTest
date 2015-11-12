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
#import <mach/machine.h>

static BOOL deviceIsCharging;
static double deviceBatteryLevel;

@implementation TEALDeviceDataSources

#pragma mark - PUBLIC

+ (NSDictionary *) backgroundDataSources{
    
    // get runtime changable default data
    NSString *architecture = [self architecture];
    NSString *cpuType = [self cpuType];
    NSString *language = [self currentLanguage];
    //    NSString *hardware = [TEALDataSources hardware];

    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    
    // if particular data is not available, skip
    if (architecture)       mDict[TEALDataSourceKey_DeviceArchitecture] = architecture;
    if (cpuType)            mDict[TEALDataSourceKey_DeviceCPUType] = cpuType;
    if (language)           mDict[TEALDataSourceKey_DeviceLanguage] = language;
    //    if (hardware)              mDict[@"device_model"] = hardware;

    
    return [NSDictionary dictionaryWithDictionary:mDict];
}

+ (NSDictionary *) mainThreadDataSources {
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];

    NSString *batteryLevel = [self batteryLevelAsPercentString];
    NSString *batteryIsCharging = [self batteryIsChargingAsString];
    NSString *device = [self model];
    NSString *orientation = [self currentOrientation];
    NSString *resolution = [self resolution];
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    if (batteryLevel)       mDict[TEALDataSourceKey_DeviceBatteryLevel] = batteryLevel;
    if (batteryIsCharging)  mDict[TEALDataSourceKey_DeviceIsCharging] = batteryIsCharging;
    if (device)             mDict[TEALDataSourceKey_Device] = device;
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
    
#ifndef TARGET_OS_TV
    
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

static NSString *deviceModel;
+ (NSString *) model {
    if (!deviceModel) {
        deviceModel = [[[UIDevice currentDevice] model] copy];
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
