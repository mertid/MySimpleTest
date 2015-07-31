//
//  TEALPublishSettings.m
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//
//  BRIEF: Native represenatation of the Mobile Publish Settings

#import "TEALPublishSettings.h"
#import "TEALLogger.h"
#import "NSString+TealiumAdditions.h"
#import "TEALPublishSettingsStore.h"
#import "TEALSystemHelpers.h"

@interface TEALPublishSettings()

@property (nonatomic, strong) TEALPublishSettingsStore *store;

@end

@implementation TEALPublishSettings

#pragma mark - SETUP

- (instancetype) initWithURLString:(NSString *)url {
    self = [super init];
    
    if (self) {
        
        // Default Remote Settings
        _url                            = url;
        _status                         = TEALPublishSettingsStatusDefault;
        _mpsVersion                     = [TEALSystemHelpers tealiumIQlibraryVersion];
        _numberOfDaysDispatchesAreValid = -1;
        _dispatchSize                   = 1;
        _offlineDispatchQueueSize       = 1000; // -1 is supposed to be inf. but yeah thats alot
        _enableLowBatterySuppress       = YES;
        _enableSendWifiOnly             = NO;
        _enableAudienceStream           = YES;
        _enableTagManagement            = NO;
//        _shouldAutotrackUIEvents        = NO;
//        _shouldAutotrackViews           = YES;
        _store = [[TEALPublishSettingsStore alloc] initWithInstanceID:url];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
        
        _url                            = [aDecoder decodeObjectForKey:@"url"];
        _mpsVersion                     = [aDecoder decodeObjectForKey:@"mpsVersion"];
        _numberOfDaysDispatchesAreValid = [aDecoder decodeIntegerForKey:@"numberOfDaysDispatchesAreValid"];
        _dispatchSize                   = [aDecoder decodeIntegerForKey:@"dispatchSize"];
        _offlineDispatchQueueSize       = [aDecoder decodeIntegerForKey:@"offlineDispatchQueueSize"];
        _enableLowBatterySuppress       = [aDecoder decodeBoolForKey:@"shouldLowBatterySuppress"];
        _enableSendWifiOnly             = [aDecoder decodeBoolForKey:@"shouldSendWifiOnly"];
        
        _enableAudienceStream           = [aDecoder decodeBoolForKey:@"enableAudienceStream"];
        _enableTagManagement            = [aDecoder decodeBoolForKey:@"enableTagManagment"];
        
//        _shouldAutotrackUIEvents        = [aDecoder decodeBoolForKey:@"autotrackUIEvents"];
//        _shouldAutotrackViews           = [aDecoder decodeBoolForKey:@"autotrackViews"];
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
    
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeObject:self.mpsVersion forKey:@"mpsVersion"];
    [aCoder encodeInteger:self.numberOfDaysDispatchesAreValid forKey:@"numberOfDaysDispatchesAreValid"];
    [aCoder encodeInteger:self.dispatchSize forKey:@"dispatchSize"];
    [aCoder encodeInteger:self.offlineDispatchQueueSize forKey:@"offlineDispatchQueueSize"];
    [aCoder encodeBool:self.enableLowBatterySuppress forKey:@"shouldLowBatterySuppress"];
    [aCoder encodeBool:self.enableSendWifiOnly forKey:@"shouldSendWifiOnly"];
    [aCoder encodeBool:self.enableAudienceStream forKey:@"enableAudienceStream"];
    [aCoder encodeBool:self.enableTagManagement forKey:@"enableTagManagment"];
//    [aCoder encodeBool:self.shouldAutotrackUIEvents forKey:@"autotrackUIEvents"];
//    [aCoder encodeBool:self.shouldAutotrackViews forKey:@"autotrackViews"];
    
}

+ (BOOL) supportsSecureCoding {
    return YES;
}

//- (void) storeTraceID:(NSString *)traceID {
//    
//    self.traceID = traceID;
//}
//
//- (void) disableTrace {
//    self.traceID = nil;
//}
//


- (NSString *) description {
    
    NSDictionary *descriptionDictionary = @{
                                            @"status":[NSString stringWithFormat:@"%lu", self.status],
                                            @"url":[NSString teal_dictionarySafeString:self.url],
                                            @"mps version":[NSString teal_dictionarySafeString:self.mpsVersion],
                                            @"dispatch size":[NSString stringWithFormat:@"%i", (int)self.dispatchSize],
                                            @"offline dispatch size":[NSString stringWithFormat:@"%i", (int)self.offlineDispatchQueueSize],
                                            @"number of day dispatches valid":[NSString stringWithFormat:@"%i",(int)self.numberOfDaysDispatchesAreValid],
                                            @"battery save mode":[NSString teal_stringFromBool:self.enableLowBatterySuppress],
                                            @"wifi only mode":[NSString teal_stringFromBool:self.enableSendWifiOnly],
                                            @"enable AudienceStream":[NSString teal_stringFromBool:self.enableAudienceStream],
                                            @"enable Tag Management":[NSString teal_stringFromBool:self.enableTagManagement]
//                                            @"autotrack ui events":[NSString teal_stringFromBool:self.shouldAutotrackUIEvents],
//                                            @"autotrack views":[NSString teal_stringFromBool:self.shouldAutotrackViews]
                                            };
    
    return [NSString teal_descriptionForObject:self fromDictionary:descriptionDictionary];
}

- (void) loadArchived {
    TEALPublishSettings *settings = [self.store unarchivePublishSettings];
    
    if (settings) {
        self.url = settings.url;
        self.mpsVersion = settings.mpsVersion;
        self.dispatchSize = settings.dispatchSize;
        self.offlineDispatchQueueSize = settings.offlineDispatchQueueSize;
        self.numberOfDaysDispatchesAreValid = settings.numberOfDaysDispatchesAreValid;
        self.enableLowBatterySuppress = settings.enableLowBatterySuppress;
        self.enableSendWifiOnly = settings.enableSendWifiOnly;
    //    self.shouldAutotrackUIEvents = settings.shouldAutotrackUIEvents;
    //    self.shouldAutotrackViews = settings.shouldAutotrackViews;
        
        self.status = TEALPublishSettingsStatusLoadedArchive;
    }
    
}

- (BOOL) isEqual:(id)object {
    
    if (![object isKindOfClass:([TEALPublishSettings class])]) {
        return NO;
    }
    
    TEALPublishSettings *otherSettings = object;
    
    if (![otherSettings.url isEqualToString:self.url]) return  NO;
    if (![otherSettings.mpsVersion isEqualToString:self.mpsVersion]) return  NO;
    if (otherSettings.dispatchSize != self.dispatchSize) return  NO;
    if (otherSettings.offlineDispatchQueueSize != self.offlineDispatchQueueSize) return  NO;
    if (otherSettings.numberOfDaysDispatchesAreValid != self.numberOfDaysDispatchesAreValid) return  NO;
    if (otherSettings.enableLowBatterySuppress != self.enableLowBatterySuppress) return  NO;
    if (otherSettings.enableSendWifiOnly != self.enableSendWifiOnly) return  NO;

    
    return YES;
}

#pragma mark - Update Remote Mobile Publish Settings

- (void) updateWithRawSettings:(NSDictionary *)rawPublishSettings {
    
    self.mpsVersion = [TEALSystemHelpers mpsVersionNumber];
    
    // TODO: Update to look for acceptable MPS Versions
    if (!self.mpsVersion) {
        self.status = TEALPublishSettingsStatusDisable;
        return;
    }
    
    NSDictionary *settings = rawPublishSettings[self.mpsVersion];
    
    TEAL_LogVerbose(@"Updating publish settings: %@", settings);
    
    if (!settings) {
        return;
    }
    
    [self storeDispatchSizeFromSettings:settings];
    [self storeOfflineDispatchQueueSizeFromSettings:settings];
    [self storeDispatchExpirationFromSettings:settings];
    [self storeLowBatterySuppressionFromSettings:settings];
    [self storeWifiOnlySettingFromSettings:settings];
    [self storeUIAutotrackingEnabledFromSettings:settings];
    
    self.status = TEALPublishSettingsStatusLoadedRemote;

    [self.store archivePublishSettings:self];
}



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
        self.enableLowBatterySuppress = [lowBattery boolValue];
    }
}

- (void) storeWifiOnlySettingFromSettings:(NSDictionary *)settings {

    NSString *wifiOnly = settings[@"wifi_only_sending"];

    if (wifiOnly) {
        self.enableSendWifiOnly = [wifiOnly boolValue];
    }
}

// From MPS 4.0 - enable all autotracking
- (void) storeUIAutotrackingEnabledFromSettings:(NSDictionary *)settings {

    NSString *uiAutotrackingEnabled = settings[@"ui_auto_tracking"];

    if (uiAutotrackingEnabled) {
//        self.shouldAutotrackUIEvents = [uiAutotrackingEnabled boolValue];
//        self.shouldAutotrackViews = [uiAutotrackingEnabled boolValue];
    }
}

// Stubs for MPS 5.0
- (void) storeUIEventsAutotrackingEnabledFromSettings:(NSDictionary *)settings {

}

- (void) storeViewsAutotrackingEnabledFromSettings:(NSDictionary *)settings {

}
@end
