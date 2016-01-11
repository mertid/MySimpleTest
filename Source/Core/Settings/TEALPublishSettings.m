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
#import "TEALPublishSettingsConstants.h"

NSString * const TEALPublishSettingKeyData = @"com.tealium.publishsetting.data";
NSString * const TEALPublishSettingKeyModuleDescriptionData = @"module_description_data";

@interface TEALPublishSettings()

@property (nonatomic) NSMutableDictionary *privatePublishSettingsData;
@property (nonatomic) NSMutableDictionary *privateModuleDescriptionData;
@property (nonatomic) dispatch_queue_t privateQueue;

@end


@implementation TEALPublishSettings

#pragma mark - PUBLIC CLASS

+ (NSDictionary *) mobilePublishSettingsFromJSONFile:(NSData *)data error:(NSError * __autoreleasing *)error {
    
    if (!data){
        return nil;
    }
    
    NSDictionary *resultDictionary = nil;
    
    resultDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                       options:0
                                                          error:error];
    
    if (!resultDictionary ||
        resultDictionary == nil){
        
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
                             
#warning Re-enable logging of some sort
                             
#warning this script will break if an additional var is added by the publishing engine
                             
                             if (result) {
                                 //TEAL_logDev(@"text checking result: %@", result);
                             }
                             
                             if (result.range.location != NSNotFound) {
                                 scriptContents = [dataString substringWithRange:result.range];
                                 
                                 if (scriptContents) {
                                     //TEAL_logDev(@"scriptContents: %@", scriptContents);
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
                
        *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                              description:@"Mobile publish settings not found."
                                   reason:@"No publish settings found after parsing mobile.html"
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
    
    if ([archivedSettings  isKindOfClass:[TEALPublishSettings class]]){
        
        return archivedSettings;

    } else {
        
        return [self initDefaultSettingsForURLString:url];
        
    }
}

- (instancetype) initDefaultSettingsForURLString:(NSString *)url {
    
    self = [super init];
    
    if (self) {
        
        _privatePublishSettingsData = [NSMutableDictionary dictionaryWithDictionary:[self defaultPublishSettings]];
        _status                         = TEALPublishSettingsStatusDefault;
        _url                            = url;
        
    }
    return self;
}

- (BOOL) correctMPSVersionRawPublishSettings:(NSDictionary *) rawPublishSettings {
    
    NSDictionary *settings = rawPublishSettings[self.targetVersion];
    
    if (!settings) {
        return NO;
    }
    
    return YES;
}

- (BOOL) isEqualToPublishSettings:(TEALPublishSettings *)otherPublishSettings {
    
//    if (self.dispatchSize != otherPublishSettings.dispatchSize) return NO;
//
//    if (self.enableLowBatterySuppress != otherPublishSettings.enableLowBatterySuppress) return NO;
//    if (self.enableSendWifiOnly != otherPublishSettings.enableSendWifiOnly) return NO;
//    
////    if (self.enableCollect != otherPublishSettings.enableCollect) return NO;
////    
////    if (self.enableS2SLegacy != otherPublishSettings.enableS2SLegacy) return NO;
//    
//    
//    if (self.enableTagManagement != otherPublishSettings.enableTagManagement) return NO;
//    
//    if (self.disableLibrary != otherPublishSettings.disableLibrary) return NO;
//    if (self.disableApplicationInfoAutotracking != otherPublishSettings.disableApplicationInfoAutotracking) return NO;
//    if (self.disableCarrierInfoAutotracking != otherPublishSettings.disableCarrierInfoAutotracking) return NO;
//    if (self.disableCrashAutotracking != otherPublishSettings.disableCrashAutotracking) return NO;
//    if (self.disableDeviceInfoAutotracking != otherPublishSettings.disableDeviceInfoAutotracking) return NO;
//    if (self.disableiVarAutotracking != otherPublishSettings.disableiVarAutotracking) return NO;
//    if (self.disableLifecycleAutotracking != otherPublishSettings.disableLifecycleAutotracking) return NO;
//    if (self.disableMobileCompanion != otherPublishSettings.disableMobileCompanion) return NO;
//    if (self.disableTimestampAutotracking != otherPublishSettings.disableTimestampAutotracking) return NO;
//    if (self.disableUIEventAutotracking != otherPublishSettings.disableUIEventAutotracking) return NO;
//    if (self.disableViewAutotracking != otherPublishSettings.disableViewAutotracking) return NO;
//    
//    if (self.minutesBetweenRefresh != otherPublishSettings.minutesBetweenRefresh) return NO;
//    if (self.numberOfDaysDispatchesAreValid != otherPublishSettings.numberOfDaysDispatchesAreValid) return NO;
//    if (self.offlineDispatchQueueSize != otherPublishSettings.offlineDispatchQueueSize) return NO;
//    
//    // isEqualToString returns NO if both strings are nil - should return YES for our use
//    if ((self.privateOverrideLogLevel && otherPublishSettings.privateOverrideLogLevel) &&
//        ![self.privateOverrideLogLevel isEqualToString:otherPublishSettings.privateOverrideLogLevel]) return NO;
    
    if (![[self publishSettingsData] isEqualToDictionary:[otherPublishSettings publishSettingsData]]) return NO;
    
    if (self.status != otherPublishSettings.status) return NO;
    
//    if (![self.url isEqualToString:otherPublishSettings.url]) return NO;

#warning Test this
    
    if (![[self moduleDescriptionData] isEqualToDictionary:[otherPublishSettings moduleDescriptionData]]){
        return NO;
    }
    
    return YES;
}

- (BOOL) areNewRawPublishSettings:(NSDictionary *)rawPublishSettings {
    
    return ![rawPublishSettings isEqualToDictionary:self.privatePublishSettingsData];
   
}

- (void) updateWithRawSettings:(NSDictionary *)rawPublishSettings {
    
    NSDictionary *settings = rawPublishSettings[self.targetVersion];
    
    if (!settings) {
        return;
    }
    
    [self importLocalSettingsFromRawSettings:settings];
    
    self.privatePublishSettingsData = [NSMutableDictionary dictionaryWithDictionary:settings];
    
    [TEALPublishSettingsStore archivePublishSettings:self];
    
}

- (BOOL) enableLowBatterySuppress {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyLowBatteryMode];
    
    if (![number isKindOfClass:[NSNumber class]]){
        return NO;
    }
    
    return [number boolValue];
    
}

- (BOOL) enableSendWifiOnly {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyWifiOnlyMode];
    
    if (![number isKindOfClass:[NSNumber class]]){
        return NO;
    }
    
    return [number boolValue];
    
}

- (BOOL) disableLibrary {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyIsEnabled];
    
    if (![number isKindOfClass:[NSNumber class]]){
        return NO;
    }
    
    return [number boolValue];
}

- (double) minutesBetweenRefresh {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyMinutesBetweenRefresh];
    
    if (![number isKindOfClass:[NSNumber class]]){
        return NO;
    }
    
    return [number doubleValue];
    
}

- (double) numberOfDaysDispatchesAreValid {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyDispatchExpiration];
    
    if (![number isKindOfClass:[NSNumber class]]){
        return NO;
    }
    
    return [number doubleValue];
}

- (NSString *) overrideLogLevel {

    NSString *string = [self publishSettingsData][TEALPublishSettingKeyOverrideLog];
    
    if (![string isKindOfClass:[NSString class]]){
        return nil;
    }
    
    return [string lowercaseString];

}

- (NSUInteger) dispatchSize {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyDispatchSize];
    
    if (![number isKindOfClass:[NSNumber class]]){
        return 0;
    }
    
    return [number integerValue];
}

- (NSUInteger) offlineDispatchQueueSize {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyOfflineDispatchSize];
    
    if (![number isKindOfClass:[NSNumber class]]){
        return 0;
    }
    
    return [number integerValue];
    
}

#pragma mark - PRIVATE

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
    
//        _dispatchSize                   = [aDecoder decodeIntegerForKey:@"dispatchSize"];
//        _offlineDispatchQueueSize       = [aDecoder decodeIntegerForKey:@"offlineDispatchQueueSize"];
//        _enableLowBatterySuppress       = [aDecoder decodeBoolForKey:@"shouldLowBatterySuppress"];
//        _enableSendWifiOnly             = [aDecoder decodeBoolForKey:@"shouldSendWifiOnly"];
//        _enableCollect           = [aDecoder decodeBoolForKey:TEALPublishSettingKeyCollectEnable];
//        _enableS2SLegacy            = [aDecoder decodeBoolForKey:TEALPublishSettingKeyS2SLegacyEnable];
//        _enableTagManagement            = [aDecoder decodeBoolForKey:TEALPublishSettingKeyTagManagementEnable];
//        
//        _disableLibrary = [aDecoder decodeBoolForKey:@"disableLibrary"];
        
//        _disableApplicationInfoAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableApplicationInfoAutotracking];
//        _disableCarrierInfoAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableCarrierInfoAutotracking];
//        _disableDeviceInfoAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableDeviceInfoAutotracking];
//        _disableUIEventAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableUIEventAutotracking];
//        _disableViewAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableViewAutotracking];
//        _disableiVarAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableiVarAutotracking];
//        _disableLifecycleAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableLifecycleAutotracking];
//        _disableTimestampAutotracking = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableTimestampAutotracking];
//        _disableCrashAutotracking   = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableCrashAutotracking];
//        _disableMobileCompanion = [aDecoder decodeBoolForKey:TEALPublishSettingKeyDisableMobileCompanion];
        
//        _minutesBetweenRefresh          = [aDecoder decodeDoubleForKey:TEALPublishSettingKeyMinutesBetweenRefresh];
        
//        _privateModuleData = [aDecoder decodeObjectForKey:TEALPublishSettingKeyModuleData];
//        _numberOfDaysDispatchesAreValid = [aDecoder decodeDoubleForKey:TEALPublishSettingKeyDispatchExpiration];
//        _privateOverrideLogLevel = [aDecoder decodeObjectForKey:TEALPublishSettingKeyOverrideLog];
//        _url                            = [aDecoder decodeObjectOfClass:[NSString class] forKey:TEALPublishSettingKeyUrl];

        _privateModuleDescriptionData = [aDecoder decodeObjectForKey:TEALPublishSettingKeyModuleDescriptionData];

        _privatePublishSettingsData = [aDecoder decodeObjectForKey:TEALPublishSettingKeyData];
        
        _targetVersion = [aDecoder decodeObjectForKey:@"version"];
        
        TEALPublishSettingsStatus status = [aDecoder decodeIntegerForKey:@"status"];
        if (status == TEALPublishSettingsStatusLoadedRemote) {
            status = TEALPublishSettingsStatusLoadedArchive;
        }
        _status = status;
    }
    
    return self;
}

- (dispatch_queue_t) queue {
    
    if (!self.privateQueue){
        NSString *fullQueueName = [NSString stringWithFormat:@"tealium.publishsettings.queue.%@", self.url];
        const char * queueName = [fullQueueName UTF8String];
        self.privateQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self.privateQueue;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    
//    [aCoder encodeObject:self.url forKey:TEALPublishSettingKeyUrl];
//    [aCoder encodeDouble:self.minutesBetweenRefresh forKey:TEALPublishSettingKeyMinutesBetweenRefresh];
//    [aCoder encodeDouble:self.numberOfDaysDispatchesAreValid forKey:TEALPublishSettingKeyDispatchExpiration];
//    [aCoder encodeInteger:self.dispatchSize forKey:@"dispatchSize"];
//    [aCoder encodeInteger:self.offlineDispatchQueueSize forKey:@"offlineDispatchQueueSize"];
//    [aCoder encodeBool:self.enableLowBatterySuppress forKey:@"shouldLowBatterySuppress"];
//    [aCoder encodeBool:self.enableSendWifiOnly forKey:@"shouldSendWifiOnly"];
//    [aCoder encodeBool:self.enableCollect forKey:TEALPublishSettingKeyCollectEnable];
//    [aCoder encodeBool:self.enableS2SLegacy forKey:TEALPublishSettingKeyS2SLegacyEnable];
//    [aCoder encodeBool:self.enableTagManagement forKey:TEALPublishSettingKeyTagManagementEnable];
//
//    [aCoder encodeBool:self.disableLibrary forKey:@"disableLibrary"];
//    [aCoder encodeBool:self.disableApplicationInfoAutotracking forKey:TEALPublishSettingKeyDisableApplicationInfoAutotracking];
//    [aCoder encodeBool:self.disableCarrierInfoAutotracking forKey:TEALPublishSettingKeyDisableCarrierInfoAutotracking];
//    [aCoder encodeBool:self.disableDeviceInfoAutotracking forKey:TEALPublishSettingKeyDisableDeviceInfoAutotracking];
//    [aCoder encodeBool:self.disableUIEventAutotracking forKey:TEALPublishSettingKeyDisableUIEventAutotracking];
//    [aCoder encodeBool:self.disableViewAutotracking forKey:TEALPublishSettingKeyDisableViewAutotracking];
//    
//    [aCoder encodeBool:self.disableiVarAutotracking forKey:TEALPublishSettingKeyDisableiVarAutotracking];
//    [aCoder encodeBool:self.disableLifecycleAutotracking forKey:TEALPublishSettingKeyDisableLifecycleAutotracking];
//    [aCoder encodeBool:self.disableTimestampAutotracking forKey:TEALPublishSettingKeyDisableTimestampAutotracking];
//    [aCoder encodeBool:self.disableCrashAutotracking forKey:TEALPublishSettingKeyDisableCrashAutotracking];
//    [aCoder encodeBool:self.disableMobileCompanion forKey:TEALPublishSettingKeyDisableMobileCompanion];
//    [aCoder encodeObject:self.privateOverrideLogLevel forKey:TEALPublishSettingKeyOverrideLog];
    
//    [aCoder encodeObject:self.privateModuleData forKey:TEALPublishSettingKeyModuleData];
    
    [aCoder encodeInteger:self.status forKey:@"status"];
    
    [aCoder encodeObject:self.targetVersion forKey:@"targetVersion"];
    
    [aCoder encodeObject:[self publishSettingsData] forKey:TEALPublishSettingKeyData];
    
    [aCoder encodeObject:self.privateModuleDescriptionData forKey:TEALPublishSettingKeyModuleDescriptionData];
    
}

- (NSDictionary *) defaultPublishSettings {
    
    return @{
             TEALPublishSettingKeyDispatchExpiration : @(-1),
             TEALPublishSettingKeyDispatchSize : @(1),
             TEALPublishSettingKeyIsEnabled : @(1),
             TEALPublishSettingKeyMinutesBetweenRefresh : @(0.0),
             TEALPublishSettingKeyLowBatteryMode : @(1),
             TEALPublishSettingKeyOfflineDispatchSize : @(100),
             TEALPublishSettingKeyTagManagementEnable : @(0),
             TEALPublishSettingKeyWifiOnlyMode : @(0)
             };
}

- (void) importLocalSettingsFromRawSettings:(NSDictionary *)settings {
    
    // Referencing keys from MPS Json object - keep keys separate from encoder keys for clarity
    
//    NSString *batchSize = settings[TEALPublishSettingKeyDispatchSize];
//    NSString *offlineSize = settings[TEALPublishSettingKeyOfflineDispatchSize];
//    NSString *minutesBetweenRefresh = settings[TEALPublishSettingKeyMinutesBetweenRefresh];
//    NSString *dispatchExpiration = settings[TEALPublishSettingKeyDispatchExpiration];
//    NSString *lowBattery = settings[TEALPublishSettingKeyLowBatteryMode];
//    NSString *wifiOnly = settings[TEALPublishSettingKeyWifiOnlyMode];
////    NSString *audiencestream = settings[TEALPublishSettingKeyCollectEnable];
////    NSString *s2SLegacy = settings[TEALPublishSettingKeyS2SLegacyEnable];
//    NSString *tagmanagement = settings[TEALPublishSettingKeyTagManagementEnable];
//    NSString *overrideLog = [settings[TEALPublishSettingKeyOverrideLog] lowercaseString];
//    
//    NSString *disableLibrary = settings[TEALPublishSettingKeyIsEnabled];
    
//    NSString *disableApplicationInfoAutotracking = settings[TEALPublishSettingKeyDisableApplicationInfoAutotracking];
//    NSString *disableCarrierInfoAutotracking = settings[TEALPublishSettingKeyDisableCarrierInfoAutotracking];
//    NSString *disableDeviceInfoAutotracking = settings[TEALPublishSettingKeyDisableDeviceInfoAutotracking];
//    NSString *disableUIEventAutotracking = settings[TEALPublishSettingKeyDisableUIEventAutotracking];
//    NSString *disableViewAutotracking = settings[TEALPublishSettingKeyDisableViewAutotracking];
//    NSString *disableiVarAutotracking = settings[TEALPublishSettingKeyDisableiVarAutotracking];
//    NSString *disableLifecycleAutotracking = settings[TEALPublishSettingKeyDisableLifecycleAutotracking];
//    NSString *disableTimestampAutotracking = settings[TEALPublishSettingKeyDisableTimestampAutotracking];
//    NSString *disableCrashAutotracking = settings[TEALPublishSettingKeyDisableCrashAutotracking];
//    NSString *disableMobileCompanion = settings[TEALPublishSettingKeyDisableMobileCompanion];
    
    
//    if (batchSize) {
//        self.dispatchSize = [batchSize integerValue];
//    }
//    
//    if (offlineSize) {
//        self.offlineDispatchQueueSize = [offlineSize integerValue];
//    }
//    
//    if (minutesBetweenRefresh) {
//        
//        self.minutesBetweenRefresh = [minutesBetweenRefresh doubleValue];
//        
//    }
//    
//    if (dispatchExpiration) {
//        self.numberOfDaysDispatchesAreValid = [dispatchExpiration doubleValue];
//    }
//    
//    if (lowBattery) {
//        self.enableLowBatterySuppress = [lowBattery boolValue];
//    }
//    
//    if (wifiOnly) {
//        self.enableSendWifiOnly = [wifiOnly boolValue];
//    }
    
//    if (audiencestream) {
//        self.enableCollect = [audiencestream boolValue];
//    }
//    
//    if (s2SLegacy){
//        self.enableS2SLegacy = [s2SLegacy boolValue];
//    }
    
//    if (tagmanagement) {
//        self.enableTagManagement = [tagmanagement boolValue];
//    }
//    
//    if (disableLibrary){
//        self.disableLibrary = [disableLibrary boolValue];
//    }
    
//    if (disableApplicationInfoAutotracking){
//        self.disableApplicationInfoAutotracking = [disableApplicationInfoAutotracking boolValue];
//    }
//    
//    if (disableCarrierInfoAutotracking) {
//        self.disableCarrierInfoAutotracking = [disableCarrierInfoAutotracking boolValue];
//    }
//    
//    if (disableDeviceInfoAutotracking) {
//        self.disableDeviceInfoAutotracking = [disableDeviceInfoAutotracking boolValue];
//    }
//    
//    if (disableUIEventAutotracking) {
//        self.disableUIEventAutotracking = [disableUIEventAutotracking boolValue];
//    }
//    
//    if (disableViewAutotracking) {
//        self.disableViewAutotracking = [disableViewAutotracking boolValue];
//    }
//    
//    if (disableiVarAutotracking) {
//        self.disableiVarAutotracking = [disableiVarAutotracking boolValue];
//    }
//    
//    if (disableLifecycleAutotracking) {
//        self.disableLifecycleAutotracking = [disableLifecycleAutotracking boolValue];
//    }
//    
//    if (disableTimestampAutotracking) {
//        self.disableTimestampAutotracking = [disableTimestampAutotracking boolValue];
//    }
//    
//    if (disableCrashAutotracking) {
//        self.disableCrashAutotracking = [disableCrashAutotracking boolValue];
//    }
//    
//    if (disableMobileCompanion) {
//        self.disableMobileCompanion = [disableMobileCompanion boolValue];
//    }
    
//    if (overrideLog) {
//        self.privateOverrideLogLevel = overrideLog;
//    }
    
    self.privatePublishSettingsData = [NSMutableDictionary dictionaryWithDictionary:settings];
    
    self.status = TEALPublishSettingsStatusLoadedRemote;
    
}

- (NSDictionary *) baseDescriptionData {
    
    return @{
            @"status":[NSString stringWithFormat:@"%lu", (unsigned long)self.status],
            @"libray enabled":[NSString teal_stringFromBool:![self disableLibrary]],
            @"url":[NSString teal_dictionarySafeString:self.url],
            @"mps version":[NSString teal_dictionarySafeString:self.targetVersion],
            @"dispatch size":[NSString stringWithFormat:@"%i", (int)[self dispatchSize]],
            @"offline dispatch size":[NSString stringWithFormat:@"%i", (int)[self offlineDispatchQueueSize]],
            @"minutes between refresh":[NSString stringWithFormat:@"%f", (double)self.minutesBetweenRefresh],
            @"number of day dispatches valid":[NSString stringWithFormat:@"%f",(double)self.numberOfDaysDispatchesAreValid],
            @"battery save mode":[NSString teal_stringFromBool:self.enableLowBatterySuppress],
            @"wifi only mode":[NSString teal_stringFromBool:self.enableSendWifiOnly],
//            @"enable Collect":[NSString teal_stringFromBool:self.enableCollect],
//            @"enable S2S Legacy":[NSString teal_stringFromBool:self.enableS2SLegacy],
//            @"enable Tag Management":[NSString teal_stringFromBool:self.enableTagManagement],
            @"override log level":[NSString teal_dictionarySafeString:[self overrideLogLevel]]
            };
}

- (NSDictionary *) finalDescriptionData {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[self baseDescriptionData]];
    
    [mDict addEntriesFromDictionary:[self moduleDescriptionData]];
    
    return [NSDictionary dictionaryWithDictionary:mDict];
    
}

- (NSString *) description {
    
    NSDictionary *descriptionData = [self finalDescriptionData];
    
    NSString *description = [NSString stringWithFormat:@"Remote settings from %@", [TEALPublishSettings statusStringFromPublishSettingStatusType:self.status]];
    
    return [NSString teal_descriptionForObject:self description:description fromDictionary:descriptionData];
    
}

#pragma mark - MODULE DATA

- (NSMutableDictionary *) publishSettingsData {
    
    if (!self.privatePublishSettingsData){
        self.privatePublishSettingsData = [NSMutableDictionary new];
    }
    
    return self.privatePublishSettingsData;
    
}

- (id) publishSettingsDataObjectForKey:(id<NSCopying, NSSecureCoding>)key {
    
    __block id obj = nil;
    
    dispatch_sync([self queue], ^{
        obj = [self publishSettingsData][key];
    });
    
    return obj;
}

- (void) setPublishSettingsDataObject:(id<NSCopying, NSSecureCoding>)object
                               forKey:(id<NSCopying, NSSecureCoding>)aKey {
    
    dispatch_barrier_async([self queue], ^{
        
        [self publishSettingsData][aKey] = object;
        
    });
}

- (NSMutableDictionary *) moduleDescriptionData {
    
    if (!self.privateModuleDescriptionData) {
        self.privateModuleDescriptionData = [NSMutableDictionary new];
    }
    
    return self.privateModuleDescriptionData;
}

- (void) setModuleDescription:(NSString *) description
                       forKey:(NSString *)aKey {
    
    dispatch_barrier_async([self queue], ^{
        
        [self moduleDescriptionData][aKey] = description;
        
    });
}

@end
