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

NSString * const TEALPublishSettingKeyUrl = @"url";
NSString * const TEALPublishSettingKeyMinutesBetweenRefresh = @"minutesBetweenRefresh";
NSString * const TEALPublishSettingKeyDispatchExpiration = @"numberOfDaysDispatchesAreValid";
NSString * const TEALPublishSettingKeyDispatchSize = @"dispatchBatchSize";
NSString * const TEALPublishSettingKeyOfflineDispatchSize = @"offlineDispatchQueueSize";
NSString * const TEALPublishSettingKeyLowBatteryMode = @"shouldSuppressIfLowBattery";
NSString * const TEALPublishSettingKeyWifiOnlyMode = @"shouldSendWifiOnly";
NSString * const TEALPublishSettingKeyCollectEnable = @"shouldEnableCollect";
NSString * const TEALPublishSettingKeyTagManagmentEnable = @"shouldEnableTagManagment";
NSString * const TEALPublishSettingKeyStatus = @"status";

NSString * const TEALPublishSettingKeyDisableApplicationInfoAutotracking = @"disableApplicationInfoAutotracking";
NSString * const TEALPublishSettingKeyDisableCarrierInfoAutotracking = @"disableCarrierAutotracking";
NSString * const TEALPublishSettingKeyDisableDeviceInfoAutotracking = @"disableDeviceInfoAutotracking";
NSString * const TEALPublishSettingKeyDisableUIEventAutotracking = @"disableUIEventAutotracking";
NSString * const TEALPublishSettingKeyDisableViewAutotracking = @"disableViewAutotracking";
NSString * const TEALPublishSettingKeyDisableiVarAutotracking = @"disableiVarAutotracking";
NSString * const TEALPublishSettingKeyDisableLifecycleAutotracking = @"disableLifecycleAutotracking";
NSString * const TEALPublishSettingKeyDisableTimestampAutotracking = @"disableTimestampAutotracking";
NSString * const TEALPublishSettingKeyDisableCrashAutotracking = @"disableCrashAutotracking";
NSString * const TEALPublishSettingKeyDisableMobileCompanion = @"disableMobileCompanion";

@interface TEALPublishSettings()

@property (nonatomic, strong) TEALPublishSettingsStore *store;
@property (copy, nonatomic) NSString *mpsVersionCopy;

@end


@implementation TEALPublishSettings

#pragma mark - PUBLIC

- (instancetype) initWithURLString:(NSString *)url {
    self = [super init];
    
    if (self) {
        
        // Default Remote Settings
        _url                            = url;
        _status                         = TEALPublishSettingsStatusDefault;
        _numberOfDaysDispatchesAreValid = -1;
        _dispatchSize                   = 1;
        _offlineDispatchQueueSize       = 1000; // -1 is supposed to be inf. but yeah thats alot
        _enableLowBatterySuppress       = YES;
        _enableSendWifiOnly             = NO;
#warning FLIP enableAudienceStream TO YES FOR RELEASE
        _enableAudienceStream           = NO;
#warning FLIP enableTagManagment TO NO FOR RELEASE
        _enableTagManagement            = YES;
        _store = [[TEALPublishSettingsStore alloc] initWithInstanceID:url];
    }
    return self;
}

- (BOOL) areValidRawPublishSettings:(NSDictionary *) rawPublishSettings {
    
    NSDictionary *settings = rawPublishSettings[[self mpsVersion]];
    
    if (!settings) {
        return NO;
    }
    
    return YES;
}

- (void) updateWithRawSettings:(NSDictionary *)rawPublishSettings {
    
    NSDictionary *settings = rawPublishSettings[[self mpsVersion]];
    
    if (!settings) {
        return;
    }
    
    [self storeLocalSettingsFromRawSettings:settings];
    
    self.status = TEALPublishSettingsStatusLoadedRemote;
    
    [self.store archivePublishSettings:self];
}

- (void) loadArchived {
    TEALPublishSettings *settings = [self.store unarchivePublishSettings];
    
    if (settings) {
        self.url = settings.url;
        self.dispatchSize = settings.dispatchSize;
        self.offlineDispatchQueueSize = settings.offlineDispatchQueueSize;
        self.numberOfDaysDispatchesAreValid = settings.numberOfDaysDispatchesAreValid;
        self.enableLowBatterySuppress = settings.enableLowBatterySuppress;
        self.enableSendWifiOnly = settings.enableSendWifiOnly;
        self.status = TEALPublishSettingsStatusLoadedArchive;
    }
    
}

- (NSString *) mpsVersion {
    if (!self.mpsVersionCopy) {
        self.mpsVersionCopy = [[TEALSystemHelpers mpsVersionNumber] copy];
    }
    return self.mpsVersionCopy;
}

- (NSDictionary *) mobilePublishSettingsFromHTMLData:(NSData *)data error:(NSError **)error {
    
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
                                 //                                 TEAL_LogVerbose(@"text checking result: %@", result);
                             }
                             
                             if (result.range.location != NSNotFound) {
                                 scriptContents = [dataString substringWithRange:result.range];
                                 
                                 if (scriptContents) {
                                     //                                     TEAL_LogVerbose(@"scriptContents: %@", scriptContents);
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
        
        //        TEAL_LogVerbose(@"mobile publish settings not found! old mobile library extension is not supported.  ");
        
        *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                              description:@"Mobile publish settings not found."
                                   reason:@"Mobile publish settings not found. While parsing mobile.html"
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
    
    //    TEAL_LogVerbose(@"mpsDataString: %@", mpsDataString);
    
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

#pragma mark - PRIVATE

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
        
        _url                            = [aDecoder decodeObjectOfClass:[NSString class] forKey:TEALPublishSettingKeyUrl];
        _minutesBetweenRefresh          = [aDecoder decodeDoubleForKey:TEALPublishSettingKeyMinutesBetweenRefresh];
        _numberOfDaysDispatchesAreValid = [aDecoder decodeDoubleForKey:TEALPublishSettingKeyDispatchExpiration];
        _dispatchSize                   = [aDecoder decodeIntegerForKey:@"dispatchSize"];
        _offlineDispatchQueueSize       = [aDecoder decodeIntegerForKey:@"offlineDispatchQueueSize"];
        _enableLowBatterySuppress       = [aDecoder decodeBoolForKey:@"shouldLowBatterySuppress"];
        _enableSendWifiOnly             = [aDecoder decodeBoolForKey:@"shouldSendWifiOnly"];
        _enableAudienceStream           = [aDecoder decodeBoolForKey:@"enableAudienceStream"];
        _enableTagManagement            = [aDecoder decodeBoolForKey:@"enableTagManagment"];
        
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
        _store                          = [[TEALPublishSettingsStore alloc] initWithInstanceID:_url];
        
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
    [aCoder encodeBool:self.enableAudienceStream forKey:@"enableAudienceStream"];
    [aCoder encodeBool:self.enableTagManagement forKey:@"enableTagManagment"];

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
    
}

- (BOOL) isEqual:(id)object {
    
    if (![object isKindOfClass:([TEALPublishSettings class])]) {
        return NO;
    }
    
    TEALPublishSettings *otherSettings = object;
    
    if (![otherSettings.url isEqualToString:self.url]) return  NO;
    if (otherSettings.dispatchSize != self.dispatchSize) return  NO;
    if (otherSettings.offlineDispatchQueueSize != self.offlineDispatchQueueSize) return  NO;
    if (otherSettings.minutesBetweenRefresh != self.minutesBetweenRefresh) return NO;
    if (otherSettings.numberOfDaysDispatchesAreValid != self.numberOfDaysDispatchesAreValid) return  NO;
    if (otherSettings.enableLowBatterySuppress != self.enableLowBatterySuppress) return  NO;
    if (otherSettings.enableSendWifiOnly != self.enableSendWifiOnly) return  NO;
    
    if (otherSettings.disableApplicationInfoAutotracking != self.disableApplicationInfoAutotracking) return NO;
    if (otherSettings.disableCarrierInfoAutotracking != self.disableCarrierInfoAutotracking) return NO;
    if (otherSettings.disableDeviceInfoAutotracking != self.disableDeviceInfoAutotracking) return NO;
    if (otherSettings.disableUIEventAutotracking != self.disableUIEventAutotracking) return NO;
    if (otherSettings.disableViewAutotracking != self.disableViewAutotracking) return NO;
    if (otherSettings.disableiVarAutotracking != self.disableiVarAutotracking) return NO;
    if (otherSettings.disableLifecycleAutotracking != self.disableLifecycleAutotracking) return NO;
    if (otherSettings.disableTimestampAutotracking != self.disableTimestampAutotracking) return NO;
    if (otherSettings.disableCrashAutotracking != self.disableCrashAutotracking) return NO;
    if (otherSettings.disableMobileCompanion != self.disableMobileCompanion) return NO;
    
    return YES;
}

- (void) storeLocalSettingsFromRawSettings:(NSDictionary *)settings {
    
    // Referencing keys from MPS Json object - keep keys separate from encoder keys for clarity
    
    NSString *batchSize = settings[@"event_batch_size"];
    NSString *offlineSize = settings[@"offline_dispatch_limit"];
    NSString *minutesBetweenRefresh = settings[@"minutes_between_refresh"];
    NSString *dispatchExpiration = settings[@"dispatch_expiration"];
    NSString *lowBattery = settings[@"battery_saver"];
    NSString *wifiOnly = settings[@"wifi_only_sending"];
    NSString *audiencestream = settings[@"audiencestream"];
    NSString *tagmanagement = settings[@"tag_management"];
    
    NSString *disableApplicationInfoAutotracking = settings[@"disable_application_info_autotracking"];
    NSString *disableCarrierInfoAutotracking = settings[@"disable_carrer_info_autotracking"];
    NSString *disableDeviceInfoAutotracking = settings[@"disable_device_info_autotracking"];
    NSString *disableUIEventAutotracking = settings[@"disable_uievent_autotracking"];
    NSString *disableViewAutotracking = settings[@"disable_view_autotracking"];
    NSString *disableiVarAutotracking = settings[@"disable_ivar_autotracking"];
    NSString *disableLifecycleAutotracking = settings[@"disable_lifecycle_autotracking"];
    NSString *disableTimestampAutotracking = settings[@"disable_timestamp_autotracking"];
    NSString *disableCrashAutotracking = settings[@"disable_crash_autotracking"];
    NSString *disableMobileCompanion = settings[@"disable_mobilecompanion"];
    
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
        self.enableAudienceStream = [audiencestream boolValue];
    }
    
    if (tagmanagement) {
        self.enableTagManagement = [tagmanagement boolValue];
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
}

- (NSString *) description {
    
    NSDictionary *descriptionDictionary = @{
                                            @"status":[NSString stringWithFormat:@"%lu", (unsigned long)self.status],
                                            @"url":[NSString teal_dictionarySafeString:self.url],
                                            @"mps version":[NSString teal_dictionarySafeString:self.mpsVersion],
                                            @"dispatch size":[NSString stringWithFormat:@"%i", (int)self.dispatchSize],
                                            @"offline dispatch size":[NSString stringWithFormat:@"%i", (int)self.offlineDispatchQueueSize],
                                            @"minutes between refresh":[NSString stringWithFormat:@"%f", (double)self.minutesBetweenRefresh],
                                            @"number of day dispatches valid":[NSString stringWithFormat:@"%f",(double)self.numberOfDaysDispatchesAreValid],
                                            @"battery save mode":[NSString teal_stringFromBool:self.enableLowBatterySuppress],
                                            @"wifi only mode":[NSString teal_stringFromBool:self.enableSendWifiOnly],
                                            @"enable AudienceStream":[NSString teal_stringFromBool:self.enableAudienceStream],
                                            @"enable Tag Management":[NSString teal_stringFromBool:self.enableTagManagement]
                                            };
    
    return [NSString teal_descriptionForObject:self description:@"Remote settings from TIQ" fromDictionary:descriptionDictionary];
}


@end
