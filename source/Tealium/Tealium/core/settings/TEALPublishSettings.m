//
//  TEALPublishSettings.m
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: Native represenatation of the Mobile Publish Settings

#import "TEALPublishSettings.h"
#import "NSString+Tealium.h"
#import "TEALPublishSettingsStore.h"
#import "TEALSystemHelpers.h"
#import "TEALError.h"


NSString * const TEALPublishSettingKeyIsEnabled = @"_is_enabled";
NSString * const TEALPublishSettingKeyOverrideLog = @"override_log";

NSString * const TEALPublishSettingKeyUrl = @"url";
NSString * const TEALPublishSettingKeyMinutesBetweenRefresh = @"minutes_between_refresh";
NSString * const TEALPublishSettingKeyDispatchExpiration = @"dispatch_expiration"; // Number of days dispatch is valid
NSString * const TEALPublishSettingKeyDispatchSize = @"event_batch_size";
NSString * const TEALPublishSettingKeyOfflineDispatchSize = @"offline_dispatch_limit";
NSString * const TEALPublishSettingKeyLowBatteryMode = @"battery_saver";
NSString * const TEALPublishSettingKeyWifiOnlyMode = @"wifi_only_sending";
NSString * const TEALPublishSettingKeyCollectEnable = @"enable_collect";
NSString * const TEALPublishSettingKeyS2SLegacyEnable = @"enable_s2s_legacy";
NSString * const TEALPublishSettingKeyTagManagmentEnable = @"enable_tag_management";
NSString * const TEALPublishSettingKeyStatus = @"status";

NSString * const TEALPublishSettingKeyDisableApplicationInfoAutotracking = @"disable_application_info_autotracking";
NSString * const TEALPublishSettingKeyDisableCarrierInfoAutotracking = @"disable_carrer_info_autotracking";
NSString * const TEALPublishSettingKeyDisableDeviceInfoAutotracking = @"disable_device_info_autotracking";
NSString * const TEALPublishSettingKeyDisableUIEventAutotracking = @"disable_uievent_autotracking";
NSString * const TEALPublishSettingKeyDisableViewAutotracking = @"disable_view_autotracking";
NSString * const TEALPublishSettingKeyDisableiVarAutotracking = @"disable_ivar_autotracking";
NSString * const TEALPublishSettingKeyDisableLifecycleAutotracking = @"disable_lifecycle_autotracking";
NSString * const TEALPublishSettingKeyDisableTimestampAutotracking = @"disable_timestamp_autotracking";
NSString * const TEALPublishSettingKeyDisableCrashAutotracking = @"disable_crash_autotracking";
NSString * const TEALPublishSettingKeyDisableMobileCompanion = @"disable_mobilecompanion";


@interface TEALPublishSettings()

@property (nonatomic, strong) NSDictionary *privateRawPublishSettings;

@end


@implementation TEALPublishSettings

#pragma mark - PUBLIC CLASS


+ (NSDictionary *) mobilePublishSettingsFromJSONFile:(NSData *)data error:(NSError * __autoreleasing *)error {
    
    if (!data){
        return nil;
    }
    
    NSDictionary *resultDictionary = nil;
    
    NSError *jsonError = nil;
    
    resultDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                       options:0
                                                         error:&jsonError];
    
    if (!resultDictionary){
        *error = jsonError;
        return nil;
    }
    
    return resultDictionary;
    
}

+ (NSDictionary *) mobilePublishSettingsFromHTMLData:(NSData *)data error:(NSError **)error {
    
    if (!data){
        return nil;
    }
    
    NSDictionary *resultDictionary = nil;
    
    NSString *dataString = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
    
    NSError *regexError = nil;
    
    NSString *scriptContentsPattern = @"<script.+>.+</script>";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:scriptContentsPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&regexError];
    if (!regex) {
        *error = regexError;
        return nil;
    }
    
    __block NSString *scriptContents = nil;
    
    [regex enumerateMatchesInString:dataString
                            options:NSMatchingReportCompletion
                              range:NSMakeRange(0, dataString.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             if (result) {
                                 //                                 TEAL_logDev(@"text checking result: %@", result);
                             }
                             
                             if (result.range.location != NSNotFound) {
                                 scriptContents = [dataString substringWithRange:result.range];
                                 
                                 if (scriptContents) {
                                     //                                     TEAL_logDev(@"scriptContents: %@", scriptContents);
                                 }
                                 
                                 *stop = YES;
                             }
                         }];
    
    if (!scriptContents) {
        
        return nil;
    }
    
    NSRange mpsRangeStart = [scriptContents rangeOfString:@"var mps = "
                                                  options:NSCaseInsensitiveSearch
                                                    range:NSMakeRange(0, scriptContents.length)];
    
    if (mpsRangeStart.location == NSNotFound) {
        
        //        TEAL_logDev(@"mobile publish settings not found! old mobile library extension is not supported.  ");
        
        *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                              description:@"Mobile publish settings not found."
                                   reason:@"No Mobile publish settings not found while parsing mobile.html"
                               suggestion:@"Please enable mobile publish settings in Tealium iQ."];
        
        return nil;
    }
    
    NSUInteger startIndex = NSMaxRange( mpsRangeStart );
    NSUInteger endLength = scriptContents.length - startIndex;
    NSRange mpsRangeEnd = [scriptContents rangeOfString:@"</script>"
                                                options:NSCaseInsensitiveSearch
                                                  range:NSMakeRange(startIndex, endLength)];
    
    if (mpsRangeEnd.location == NSNotFound) {
        return nil;
    }
    
    NSRange mpsRange = NSMakeRange(startIndex, ( mpsRangeEnd.location - startIndex ) );
    
    NSString *mpsDataString = [scriptContents substringWithRange:mpsRange];
        
    // TODO: check for missing utag and / or tags
    
    NSData *mpsJSONData = [mpsDataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *jsonError = nil;
    
    resultDictionary = [NSJSONSerialization JSONObjectWithData:mpsJSONData
                                                       options:NSJSONReadingMutableContainers
                                                         error:&jsonError];
    
    if (!resultDictionary) {
        *error = jsonError;
        return nil;
    }
    
    return resultDictionary;
}

+ (TEALPublishSettings *) unarchivePublishSettingsForInstanceID:(NSString *)instanceID {
    return [TEALPublishSettingsStore unarchivePublishSettingsForInstanceID:instanceID];
}

#pragma mark - PRIVATE CLASS

+ (NSString *) statusStringFromPublishSettingStatusType:(TEALPublishSettingsStatus) status {
    
    NSString *statusString = nil;
    switch (status) {
        case TEALPublishSettingsStatusLoadedArchive:
            statusString = NSLocalizedString(@"archive", @"Publish Setting Archive String");
            break;
        case TEALPublishSettingsStatusLoadedRemote:
            statusString = NSLocalizedString(@"remote", @"Publish Setting Remote String");
            break;
        case TEALPublishSettingsStatusDisable:
            statusString = NSLocalizedString(@"disable", @"Publish Setting Disable String");
            break;
        default:
            statusString = NSLocalizedString(@"default", @"Publish Setting Default String");
            break;
    }
    return statusString;
}

#pragma mark - PUBLIC

- (instancetype) initWithURLString:(NSString *)url {
    
    if (!url) {
        return nil;
    }
    
    TEALPublishSettings *archivedSettings = [TEALPublishSettingsStore unarchivePublishSettingsForInstanceID:url];
    
    if (archivedSettings){
        
        return archivedSettings;

    } else {
        
        return [self initDefaultSettingsForURLString:url];
        
    }
}

- (instancetype) initDefaultSettingsForURLString:(NSString *)url {
    
    self = [super init];
    
    if (self) {

        _dispatchSize                   = 1;
        _enableLowBatterySuppress       = YES;
        _enableSendWifiOnly             = NO;
        _enableCollect                  = NO;
        _enableS2SLegacy                = NO;
        _enableTagManagement            = NO;
        
        _disableLibrary = NO;
        _disableApplicationInfoAutotracking = NO;
        _disableCarrierInfoAutotracking = NO;
        _disableCrashAutotracking = NO;
        _disableDeviceInfoAutotracking = NO;
        _disableiVarAutotracking = NO;
        _disableLifecycleAutotracking = NO;
        _disableMobileCompanion = NO;
        _disableTimestampAutotracking = NO;
        _disableUIEventAutotracking = NO;
        _disableViewAutotracking = NO;
        
        _minutesBetweenRefresh          = 1.0;
        _numberOfDaysDispatchesAreValid = -1.0;
        _offlineDispatchQueueSize       = 100; // -1 is supposed to be inf. but yeah thats alot
        _overrideLogLevel               = nil;
        
        _status                         = TEALPublishSettingsStatusDefault;
        _url                            = url;

        
    }
    return self;
}

//- (instancetype) initWithRawPublishSettings:(NSDictionary *)rawPublishSettings{
//    
//    self = [super init];
//    
//    if (self) {
//        
//        [self updateWithRawSettings:rawPublishSettings];
//        
//    }
//    
//    return self;
//}


- (BOOL) correctMPSVersionRawPublishSettings:(NSDictionary *) rawPublishSettings {
    
    NSDictionary *settings = rawPublishSettings[self.publishSettingsVersion];
    
    if (!settings) {
        return NO;
    }
    
    return YES;
}


- (BOOL) isEqualToPublishSettings:(TEALPublishSettings *)otherPublishSettings {
    
    if (self.dispatchSize != otherPublishSettings.dispatchSize) return NO;

    if (self.enableLowBatterySuppress != otherPublishSettings.enableLowBatterySuppress) return NO;
    if (self.enableSendWifiOnly != otherPublishSettings.enableSendWifiOnly) return NO;
    if (self.enableCollect != otherPublishSettings.enableCollect) return NO;
    if (self.enableS2SLegacy != otherPublishSettings.enableS2SLegacy) return NO;
    if (self.enableTagManagement != otherPublishSettings.enableTagManagement) return NO;
    
    if (self.disableLibrary != otherPublishSettings.disableLibrary) return NO;
    if (self.disableApplicationInfoAutotracking != otherPublishSettings.disableApplicationInfoAutotracking) return NO;
    if (self.disableCarrierInfoAutotracking != otherPublishSettings.disableCarrierInfoAutotracking) return NO;
    if (self.disableCrashAutotracking != otherPublishSettings.disableCrashAutotracking) return NO;
    if (self.disableDeviceInfoAutotracking != otherPublishSettings.disableDeviceInfoAutotracking) return NO;
    if (self.disableiVarAutotracking != otherPublishSettings.disableiVarAutotracking) return NO;
    if (self.disableLifecycleAutotracking != otherPublishSettings.disableLifecycleAutotracking) return NO;
    if (self.disableMobileCompanion != otherPublishSettings.disableMobileCompanion) return NO;
    if (self.disableTimestampAutotracking != otherPublishSettings.disableTimestampAutotracking) return NO;
    if (self.disableUIEventAutotracking != otherPublishSettings.disableUIEventAutotracking) return NO;
    if (self.disableViewAutotracking != otherPublishSettings.disableViewAutotracking) return NO;
    
    if (self.minutesBetweenRefresh != otherPublishSettings.minutesBetweenRefresh) return NO;
    if (self.numberOfDaysDispatchesAreValid != otherPublishSettings.numberOfDaysDispatchesAreValid) return NO;
    if (self.offlineDispatchQueueSize != otherPublishSettings.offlineDispatchQueueSize) return NO;
    if (![self.overrideLogLevel isEqualToString:otherPublishSettings.overrideLogLevel]) return NO;
    if (self.status != otherPublishSettings.status) return NO;
    if (![self.url isEqualToString:otherPublishSettings.url]) return NO;

    return YES;
}

- (BOOL) areNewRawPublishSettings:(NSDictionary *)rawPublishSettings {
    
    return ![rawPublishSettings isEqualToDictionary:self.privateRawPublishSettings];
   
}

- (void) updateWithRawSettings:(NSDictionary *)rawPublishSettings {
    
    NSDictionary *settings = rawPublishSettings[self.publishSettingsVersion];
    
    if (!settings) {
        return;
    }
    
    [self importLocalSettingsFromRawSettings:settings];
    
    self.privateRawPublishSettings = settings;
    
    [TEALPublishSettingsStore archivePublishSettings:self];
    
}

#pragma mark - PRIVATE

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
    
        _dispatchSize                   = [aDecoder decodeIntegerForKey:@"dispatchSize"];
        _offlineDispatchQueueSize       = [aDecoder decodeIntegerForKey:@"offlineDispatchQueueSize"];
        _enableLowBatterySuppress       = [aDecoder decodeBoolForKey:@"shouldLowBatterySuppress"];
        _enableSendWifiOnly             = [aDecoder decodeBoolForKey:@"shouldSendWifiOnly"];
        _enableCollect           = [aDecoder decodeBoolForKey:TEALPublishSettingKeyCollectEnable];
        _enableS2SLegacy            = [aDecoder decodeBoolForKey:TEALPublishSettingKeyS2SLegacyEnable];
        _enableTagManagement            = [aDecoder decodeBoolForKey:TEALPublishSettingKeyTagManagmentEnable];
        
        _disableLibrary = [aDecoder decodeBoolForKey:@"disableLibrary"];
        _disableApplicationInfoAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableApplicationInfoAutotracking];
        _disableCarrierInfoAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableCarrierInfoAutotracking];
        _disableDeviceInfoAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableDeviceInfoAutotracking];
        _disableUIEventAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableUIEventAutotracking];
        _disableViewAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableViewAutotracking];
        _disableiVarAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableiVarAutotracking];
        _disableLifecycleAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableLifecycleAutotracking];
        _disableTimestampAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableTimestampAutotracking];
        _disableCrashAutotracking   = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableCrashAutotracking];
        _disableMobileCompanion = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableMobileCompanion];
        
        _minutesBetweenRefresh          = [aDecoder decodeDoubleForKey:TEALPublishSettingKeyMinutesBetweenRefresh];
        _numberOfDaysDispatchesAreValid = [aDecoder decodeDoubleForKey:TEALPublishSettingKeyDispatchExpiration];
        _overrideLogLevel = [aDecoder decodeObjectForKey:TEALPublishSettingKeyOverrideLog];
        _url                            = [aDecoder decodeObjectOfClass:[NSString class] forKey:TEALPublishSettingKeyUrl];

        TEALPublishSettingsStatus status = [aDecoder decodeIntegerForKey:@"status"];
        if (status == TEALPublishSettingsStatusLoadedRemote) {
            status = TEALPublishSettingsStatusLoadedArchive;
        }
        _status = status;
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.url forKey:TEALPublishSettingKeyUrl];
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeDouble:self.minutesBetweenRefresh forKey:TEALPublishSettingKeyMinutesBetweenRefresh];
    [aCoder encodeDouble:self.numberOfDaysDispatchesAreValid forKey:TEALPublishSettingKeyDispatchExpiration];
    [aCoder encodeInteger:self.dispatchSize forKey:@"dispatchSize"];
    [aCoder encodeInteger:self.offlineDispatchQueueSize forKey:@"offlineDispatchQueueSize"];
    [aCoder encodeBool:self.enableLowBatterySuppress forKey:@"shouldLowBatterySuppress"];
    [aCoder encodeBool:self.enableSendWifiOnly forKey:@"shouldSendWifiOnly"];
    [aCoder encodeBool:self.enableCollect forKey:TEALPublishSettingKeyCollectEnable];
    [aCoder encodeBool:self.enableS2SLegacy forKey:TEALPublishSettingKeyS2SLegacyEnable];
    [aCoder encodeBool:self.enableTagManagement forKey:TEALPublishSettingKeyTagManagmentEnable];

    [aCoder encodeBool:self.disableLibrary forKey:@"disableLibrary"];
    [aCoder encodeBool:self.disableApplicationInfoAutotracking forKey:TEALPublishSettingKeyDisableApplicationInfoAutotracking];
    [aCoder encodeBool:self.disableCarrierInfoAutotracking forKey:TEALPublishSettingKeyDisableCarrierInfoAutotracking];
    [aCoder encodeBool:self.disableDeviceInfoAutotracking forKey:TEALPublishSettingKeyDisableDeviceInfoAutotracking];
    [aCoder encodeBool:self.disableUIEventAutotracking forKey:TEALPublishSettingKeyDisableUIEventAutotracking];
    [aCoder encodeBool:self.disableViewAutotracking forKey:TEALPublishSettingKeyDisableViewAutotracking];
    [aCoder encodeBool:self.disableiVarAutotracking forKey:TEALPublishSettingKeyDisableiVarAutotracking];
    [aCoder encodeBool:self.disableLifecycleAutotracking forKey:TEALPublishSettingKeyDisableLifecycleAutotracking];
    [aCoder encodeBool:self.disableTimestampAutotracking forKey:TEALPublishSettingKeyDisableTimestampAutotracking];
    [aCoder encodeBool:self.disableCrashAutotracking forKey:TEALPublishSettingKeyDisableCrashAutotracking];
    [aCoder encodeBool:self.disableMobileCompanion forKey:TEALPublishSettingKeyDisableMobileCompanion];
    
    [aCoder encodeObject:self.overrideLogLevel forKey:TEALPublishSettingKeyOverrideLog];
    
}

- (void) importLocalSettingsFromRawSettings:(NSDictionary *)settings {
    
    // Referencing keys from MPS Json object - keep keys separate from encoder keys for clarity
    
    NSString *batchSize = settings[TEALPublishSettingKeyDispatchSize];
    NSString *offlineSize = settings[TEALPublishSettingKeyOfflineDispatchSize];
    NSString *minutesBetweenRefresh = settings[TEALPublishSettingKeyMinutesBetweenRefresh];
    NSString *dispatchExpiration = settings[TEALPublishSettingKeyDispatchExpiration];
    NSString *lowBattery = settings[TEALPublishSettingKeyLowBatteryMode];
    NSString *wifiOnly = settings[TEALPublishSettingKeyWifiOnlyMode];
    NSString *audiencestream = settings[TEALPublishSettingKeyCollectEnable];
    NSString *s2SLegacy = settings[TEALPublishSettingKeyS2SLegacyEnable];
    NSString *tagmanagement = settings[TEALPublishSettingKeyTagManagmentEnable];
    NSString *overrideLog = [settings[TEALPublishSettingKeyOverrideLog] lowercaseString];
    
    NSString *disableLibrary = settings[TEALPublishSettingKeyIsEnabled];
    NSString *disableApplicationInfoAutotracking = settings[TEALPublishSettingKeyDisableApplicationInfoAutotracking];
    NSString *disableCarrierInfoAutotracking = settings[TEALPublishSettingKeyDisableCarrierInfoAutotracking];
    NSString *disableDeviceInfoAutotracking = settings[TEALPublishSettingKeyDisableDeviceInfoAutotracking];
    NSString *disableUIEventAutotracking = settings[TEALPublishSettingKeyDisableUIEventAutotracking];
    NSString *disableViewAutotracking = settings[TEALPublishSettingKeyDisableViewAutotracking];
    NSString *disableiVarAutotracking = settings[TEALPublishSettingKeyDisableiVarAutotracking];
    NSString *disableLifecycleAutotracking = settings[TEALPublishSettingKeyDisableLifecycleAutotracking];
    NSString *disableTimestampAutotracking = settings[TEALPublishSettingKeyDisableTimestampAutotracking];
    NSString *disableCrashAutotracking = settings[TEALPublishSettingKeyDisableCrashAutotracking];
    NSString *disableMobileCompanion = settings[TEALPublishSettingKeyDisableMobileCompanion];
    
    
    if (batchSize) {
        self.dispatchSize = [batchSize integerValue];
    }
    
    if (offlineSize) {
        self.offlineDispatchQueueSize = [offlineSize integerValue];
    }
    
    if (minutesBetweenRefresh) {
        
        self.minutesBetweenRefresh = [minutesBetweenRefresh doubleValue];
        
    }
    
    if (dispatchExpiration) {
        self.numberOfDaysDispatchesAreValid = [dispatchExpiration doubleValue];
    }
    
    if (lowBattery) {
        self.enableLowBatterySuppress = [lowBattery boolValue];
    }
    
    if (wifiOnly) {
        self.enableSendWifiOnly = [wifiOnly boolValue];
    }
    
    if (audiencestream) {
        self.enableCollect = [audiencestream boolValue];
    }
    
    if (s2SLegacy){
        self.enableS2SLegacy = [s2SLegacy boolValue];
    }
    
    if (tagmanagement) {
        self.enableTagManagement = [tagmanagement boolValue];
    }
    
    if (disableLibrary){
        self.disableLibrary = [disableLibrary boolValue];
    }
    
    if (disableApplicationInfoAutotracking){
        self.disableApplicationInfoAutotracking = [disableApplicationInfoAutotracking boolValue];
    }
    
    if (disableCarrierInfoAutotracking) {
        self.disableCarrierInfoAutotracking = [disableCarrierInfoAutotracking boolValue];
    }
    
    if (disableDeviceInfoAutotracking) {
        self.disableDeviceInfoAutotracking = [disableDeviceInfoAutotracking boolValue];
    }
    
    if (disableUIEventAutotracking) {
        self.disableUIEventAutotracking = [disableUIEventAutotracking boolValue];
    }
    
    if (disableViewAutotracking) {
        self.disableViewAutotracking = [disableViewAutotracking boolValue];
    }
    
    if (disableiVarAutotracking) {
        self.disableiVarAutotracking = [disableiVarAutotracking boolValue];
    }
    
    if (disableLifecycleAutotracking) {
        self.disableLifecycleAutotracking = [disableLifecycleAutotracking boolValue];
    }
    
    if (disableTimestampAutotracking) {
        self.disableTimestampAutotracking = [disableTimestampAutotracking boolValue];
    }
    
    if (disableCrashAutotracking) {
        self.disableCrashAutotracking = [disableCrashAutotracking boolValue];
    }
    
    if (disableMobileCompanion) {
        self.disableMobileCompanion = [disableMobileCompanion boolValue];
    }
    
    if (overrideLog) {
        self.overrideLogLevel = overrideLog;
    }
    
    self.status = TEALPublishSettingsStatusLoadedRemote;
    
}

- (NSString *) description {
    
    NSDictionary *descriptionDictionary = @{
                                            @"status":[NSString stringWithFormat:@"%lu", (unsigned long)self.status],
                                            @"libray enabled":[NSString teal_stringFromBool:!self.disableLibrary],
                                            @"url":[NSString teal_dictionarySafeString:self.url],
                                            @"mps version":[NSString teal_dictionarySafeString:self.publishSettingsVersion],
                                            @"dispatch size":[NSString stringWithFormat:@"%i", (int)self.dispatchSize],
                                            @"offline dispatch size":[NSString stringWithFormat:@"%i", (int)self.offlineDispatchQueueSize],
                                            @"minutes between refresh":[NSString stringWithFormat:@"%f", (double)self.minutesBetweenRefresh],
                                            @"number of day dispatches valid":[NSString stringWithFormat:@"%f",(double)self.numberOfDaysDispatchesAreValid],
                                            @"battery save mode":[NSString teal_stringFromBool:self.enableLowBatterySuppress],
                                            @"wifi only mode":[NSString teal_stringFromBool:self.enableSendWifiOnly],
                                            @"enable Collect":[NSString teal_stringFromBool:self.enableCollect],
                                            @"enable S2S Legacy":[NSString teal_stringFromBool:self.enableS2SLegacy],
                                            @"enable Tag Management":[NSString teal_stringFromBool:self.enableTagManagement],
                                            @"override log level":[NSString teal_dictionarySafeString:self.overrideLogLevel]
                                            };
    
    NSString *description = [NSString stringWithFormat:@"Remote settings from %@", [TEALPublishSettings statusStringFromPublishSettingStatusType:self.status]];
    return [NSString teal_descriptionForObject:self description:description fromDictionary:descriptionDictionary];
}


@end
