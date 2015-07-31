//
//  TEALSettings.m
//  Tealium Mobile Library
//
//  Created by George Webster on 12/29/14.
//  Copyright (c) 2014 Tealium Inc. All rights reserved.
//

#import "TEALRemoteSettings.h"
#import "TEALSystemHelpers.h"
#import "TEALNetworkHelpers.h"
#import "NSString+TealiumAdditions.h"
#import "TEALConfiguration.h"

#import "TEALLogger.h"

@implementation TEALRemoteSettings

+ (instancetype) settingWithConfiguration:(TEALConfiguration *)configuration
                                visitorID:(NSString *)visitorID {
    
    TEALRemoteSettings *setting = [[[self class] alloc] init];
    
    if (setting) {
        setting.account                 = configuration.accountName;
        setting.tiqProfile              = configuration.profileName;
        setting.asProfile               = configuration.audienceStreamProfile;
        setting.environment             = configuration.environmentName;
        setting.visitorID               = visitorID;
        
        setting.useHTTP                 = configuration.useHTTP;
        setting.pollingFrequency        = configuration.pollingFrequency;
        setting.logLevel                = configuration.logLevel;
        setting.tagManagementEnabled    = configuration.tagManagementEnabled;
        setting.audienceStreamEnabled   = configuration.audienceStreamEnabled;
        setting.lifecycleEnabled        = configuration.lifecycleEnabled;
        setting.autotrackingUIEventsEnabled     = configuration.autotrackingUIEventsEnabled;
        setting.autotrackingViewsEnabled= configuration.autotrackingViewsEnabled;
        setting.overridePublishSettingsURL = configuration.overridePublishSettingsURL;
        setting.overridePublishURL      = configuration.overridePublishURL;
        
    }
    
    return setting;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        
        // Default Remote Settings
        
        _status                         = TEALSettingsStatusNew;
        // Configuration
        _useHTTP                        = NO;
        _pollingFrequency               = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
        // MPS
        _numberOfDaysDispatchesAreValid = -1;
        _dispatchSize                   = 1;
        _offlineDispatchQueueSize       = 1000; // -1 is supposed to be inf. but yeah thats alot
        _shouldLowBatterySuppress       = YES;
        _shouldSendWifiOnly             = NO;
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
        
        // TODO: Make constants

        // Configuration
        _account                = [aDecoder decodeObjectForKey:@"account"];
        _tiqProfile             = [aDecoder decodeObjectForKey:@"tiqProfile"];
        _asProfile              = [aDecoder decodeObjectForKey:@"asProfile"];
        _environment            = [aDecoder decodeObjectForKey:@"environment"];
        _visitorID              = [aDecoder decodeObjectForKey:@"visitorID"];
        _autotrackingUIEventsEnabled    = [aDecoder decodeBoolForKey:@"autotrackingUIEventsEnabled"];
        _autotrackingViewsEnabled       = [aDecoder decodeBoolForKey:@"autotrackingViewsEnabled"];
        _useHTTP                = [aDecoder decodeBoolForKey:@"useHTTP"];
        _pollingFrequency       = [aDecoder decodeIntegerForKey:@"pollingFrequency"];
        _overridePublishSettingsURL     = [aDecoder decodeObjectForKey:@"overridePublishSettingsURL"];
        _overridePublishURL             = [aDecoder decodeObjectForKey:@"overridePublishURL"];
        
        // MPS
        _mpsVersion                     = [aDecoder decodeObjectForKey:@"mpsVersion"];
        _numberOfDaysDispatchesAreValid = [aDecoder decodeIntegerForKey:@"numberOfDaysDispatchesAreValid"];
        _dispatchSize                   = [aDecoder decodeIntegerForKey:@"dispatchSize"];
        _offlineDispatchQueueSize       = [aDecoder decodeIntegerForKey:@"offlineDispatchQueueSize"];
        _shouldLowBatterySuppress       = [aDecoder decodeBoolForKey:@"shouldLowBatterySuppress"];
        _shouldSendWifiOnly             = [aDecoder decodeBoolForKey:@"shouldSendWifiOnly"];
        _tagManagementEnabled           = [aDecoder decodeBoolForKey:@"tagManagmentEnabled"];
        _audienceStreamEnabled          = [aDecoder decodeBoolForKey:@"audienceStreamEnabled"];
        _lifecycleEnabled               = [aDecoder decodeBoolForKey:@"lifecycleEnabled"];

        
        TEALSettingsStatus status = [aDecoder decodeIntegerForKey:@"status"];
        
        if (status == TEALSettingsStatusLoadedRemote) {
            status = TEALSettingsStatusLoadedArchive;
        }
        
        _status = status;
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeInteger:self.status forKey:@"status"];
    
    // Configuration
    [aCoder encodeObject:self.account forKey:@"account"];
    [aCoder encodeObject:self.tiqProfile forKey:@"tiqProfile"];
    [aCoder encodeObject:self.asProfile forKey:@"asProfile"];
    [aCoder encodeObject:self.environment forKey:@"environment"];
    [aCoder encodeObject:self.visitorID forKey:@"visitorID"];
    [aCoder encodeBool:self.autotrackingUIEventsEnabled forKey:@"autotrackingUIEventsEnabled"];
    [aCoder encodeBool:self.autotrackingViewsEnabled forKey:@"autotrackingViewsEnabled"];
    [aCoder encodeBool:self.useHTTP forKey:@"useHTTP"];
    [aCoder encodeInteger:self.pollingFrequency forKey:@"pollingFrequency"];
    [aCoder encodeObject:self.overridePublishSettingsURL forKey:@"overridePublishSettingsURL"];
    [aCoder encodeObject:self.overridePublishURL forKey:@"overridePublishURL"];
    
    // MPS
    [aCoder encodeObject:self.mpsVersion forKey:@"mpsVersion"];
    [aCoder encodeInteger:self.numberOfDaysDispatchesAreValid forKey:@"numberOfDaysDispatchesAreValid"];
    [aCoder encodeInteger:self.dispatchSize forKey:@"dispatchSize"];
    [aCoder encodeInteger:self.offlineDispatchQueueSize forKey:@""];
    [aCoder encodeBool:self.shouldLowBatterySuppress forKey:@"shouldLowBatterySuppress"];
    [aCoder encodeBool:self.shouldSendWifiOnly forKey:@"shouldSendWifiOnly"];
    [aCoder encodeBool:self.tagManagementEnabled forKey:@"tagManagementEnabled"];
    [aCoder encodeBool:self.audienceStreamEnabled forKey:@"audienceStreamEnabled"];
    [aCoder encodeBool:self.lifecycleEnabled forKey:@"lifecycleEnabled"];

}

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (BOOL) isValid {
    return (self.account &&
            self.tiqProfile &&
            self.asProfile &&
            self.environment &&
            self.status != TEALSettingsStatusInvalid);
}

- (void) storeTraceID:(NSString *)traceID {
    
    self.traceID = traceID;
}

- (void) disableTrace {
    self.traceID = nil;
}

- (void) storeMobilePublishSettings:(NSDictionary *)rawSettings {
    

    self.mpsVersion = [TEALSystemHelpers mpsVersionNumber];
    
    if (!self.mpsVersion) {
        return;
    }
    
    if (![self isValid]) {
        return;
    }
    
    NSDictionary *settings = rawSettings[self.mpsVersion];

    TEAL_LogVerbose(@"storing settings: %@", settings);
    
    if (!settings) {
        return;
    }
    
    [self storeDispatchSizeFromSettings:settings];
    [self storeOfflineDispatchQueueSizeFromSettings:settings];
    [self storeDispatchExpirationFromSettings:settings];
    [self storeLowBatterySuppressionFromSettings:settings];
    [self storeWifiOnlySettingFromSettings:settings];
    [self storeUIAutotrackingEnabledFromSettings:settings];
}

#pragma mark - Mobile Publish Settins

- (void) storeDispatchSizeFromSettings:(NSDictionary *)settings {

    NSString *batchSize = settings[@"event_batch_size"];
    
    if (batchSize) {
        self.dispatchSize = [batchSize integerValue];
    }
}

- (void) storeOfflineDispatchQueueSizeFromSettings:(NSDictionary *)settings {

    NSString *offlineSize = settings[@"offline_dispatch_limit"];
    
    if (offlineSize) {
        self.offlineDispatchQueueSize = [offlineSize integerValue];
    }
}

- (void) storeDispatchExpirationFromSettings:(NSDictionary *)settings {
    
    NSString *dispatchExpiration = settings[@"dispatch_expiration"];
    
    if (dispatchExpiration) {
        self.numberOfDaysDispatchesAreValid = [dispatchExpiration integerValue];
    }
}

- (void) storeLowBatterySuppressionFromSettings:(NSDictionary *)settings {
    
    NSString *lowBattery = settings[@"battery_saver"];
    
    if (lowBattery) {
        self.shouldLowBatterySuppress = [lowBattery boolValue];
    }
}

- (void) storeWifiOnlySettingFromSettings:(NSDictionary *)settings {
    
    NSString *wifiOnly = settings[@"wifi_only_sending"];
    
    if (wifiOnly) {
        self.shouldSendWifiOnly = [wifiOnly boolValue];
    }
}

// From MPS 4.0 - enable all autotracking
- (void) storeUIAutotrackingEnabledFromSettings:(NSDictionary *)settings {
    
    NSString *uiAutotrackingEnabled = settings[@"ui_auto_tracking"];
    
    if (uiAutotrackingEnabled) {
        self.autotrackingUIEventsEnabled = [uiAutotrackingEnabled boolValue];
        self.autotrackingViewsEnabled = [uiAutotrackingEnabled boolValue];
    }
}

// Stubs for MPS 5.0
//- (void) storeUIEventsAutotrackingEnabledFromSettings:(NSDictionary *)settings {
//    
//}

//- (void) storeViewsAutotrackingEnabledFromSettings:(NSDictionary *)settings {
//    
//}

- (NSString *) description {
    
    NSString *displayClass              = NSStringFromClass([self class]);
    NSString *displayHttp               = [NSString teal_stringFromBool:self.useHTTP];
    NSString *displayShouldWifiOnly     = [NSString teal_stringFromBool:self.shouldSendWifiOnly];
    NSString *displayShouldBatterySave  = [NSString teal_stringFromBool:self.shouldLowBatterySuppress];

    NSString *displayLifecycle          = [NSString teal_stringFromBool:self.lifecycleEnabled];
    NSString *displayTagManagement      = [NSString teal_stringFromBool:self.tagManagementEnabled];
    NSString *displayAudienceStream     = [NSString teal_stringFromBool:self.audienceStreamEnabled];
    NSString *displayAutotrackingUIEvents = [NSString teal_stringFromBool:self.autotrackingUIEventsEnabled];
    NSString *displayAutotrackingViews  = [NSString teal_stringFromBool:self.autotrackingViewsEnabled];
    
    NSString *displayStatus             = nil;
    
    switch (self.status) {
        case TEALSettingsStatusNew:
            displayStatus = @"new";
            break;
        case TEALSettingsStatusLoadedRemote:
            displayStatus = @"remote";
            break;
        case TEALSettingsStatusLoadedArchive:
            displayStatus = @"archive";
            break;
        case TEALSettingsStatusInvalid:
            displayStatus = @"invalid";
            break;
    }
    return [NSString stringWithFormat:@"\r%@: \r account: %@ \r tiq profile: %@ \r as profile: %@ \r environment: %@ \r visitorID: %@ \r traceID: %@ \r status: %@ \r === Configuration === \r useHttp: %@ \r pollingFrequency: %lu \r logLevel: %d \r === MPS === \r mpsVersion: %@ \r dispatchSize: %ld \r offlineQueueSize: %ld \r numberOfDaysDispatchesAreValue: %ld \r shouldLowBatterySuppress: %@ \r shouldSendWifiOnly: %@ \r lifecycleEnabled: %@ \r tagManagementEnabled: %@ \r audienceStreamEnabled: %@ \r autotrackingUIEventsEnabled: %@ \r autotrackingViewsEnabled: %@ \r overridePublishSettingsURL: %@ \r overridePublishURL: %@ \r",
            displayClass,
            self.account,
            self.tiqProfile,
            self.asProfile,
            self.environment,
            self.visitorID,
            self.traceID,
            displayStatus,
            displayHttp,
            (unsigned long)self.pollingFrequency,
            2, // log level
            self.mpsVersion,
            (unsigned long)self.dispatchSize,
            (unsigned long)self.offlineDispatchQueueSize,
            (unsigned long)self.numberOfDaysDispatchesAreValid,
            displayShouldBatterySave,
            displayShouldWifiOnly,
            displayLifecycle,
            displayTagManagement,
            displayAudienceStream,
            displayAutotrackingUIEvents,
            displayAutotrackingViews,
            self.overridePublishSettingsURL,
            self.overridePublishURL];
}

@end
