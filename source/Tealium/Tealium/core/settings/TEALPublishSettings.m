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
        _numberOfDaysDispatchesAreValid = -1;
        _dispatchSize                   = 1;
        _offlineDispatchQueueSize       = 1000; // -1 is supposed to be inf. but yeah thats alot
        _shouldLowBatterySuppress       = YES;
        _shouldSendWifiOnly             = NO;
        _store = [[TEALPublishSettingsStore alloc] initWithInstanceId:url];
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
        _shouldLowBatterySuppress       = [aDecoder decodeBoolForKey:@"shouldLowBatterySuppress"];
        _shouldSendWifiOnly             = [aDecoder decodeBoolForKey:@"shouldSendWifiOnly"];
        _store                          = [[TEALPublishSettingsStore alloc] initWithInstanceId:_url];
        
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
    [aCoder encodeInteger:self.offlineDispatchQueueSize forKey:@""];
    [aCoder encodeBool:self.shouldLowBatterySuppress forKey:@"shouldLowBatterySuppress"];
    [aCoder encodeBool:self.shouldSendWifiOnly forKey:@"shouldSendWifiOnly"];
    
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
                                            @"dispatch size":[NSString stringWithFormat:@"%lu", self. dispatchSize],
                                            @"offline dispatch size":[NSString stringWithFormat:@"%lu", self.offlineDispatchQueueSize],
                                            @"number of day dispatches valid":[NSString stringWithFormat:@"%lu",self.numberOfDaysDispatchesAreValid],
                                            @"battery save mode":[NSString teal_stringFromBool:self.shouldLowBatterySuppress],
                                            @"wifi only mode":[NSString teal_stringFromBool:self.shouldSendWifiOnly]
                                            };
    
    return [NSString teal_descriptionForObject:self fromDictionary:descriptionDictionary];
}

- (void) loadArchived {
    TEALPublishSettings *settings = [self.store unarchivePublishSettings];
    
    self.url = settings.url;
    self.mpsVersion = settings.mpsVersion;
    self.dispatchSize = settings.dispatchSize;
    self.offlineDispatchQueueSize = settings.offlineDispatchQueueSize;
    self.numberOfDaysDispatchesAreValid = settings.numberOfDaysDispatchesAreValid;
    self.shouldLowBatterySuppress = settings.shouldLowBatterySuppress;
    self.shouldSendWifiOnly = settings.shouldSendWifiOnly;
    self.shouldAutotrackUIEvents = settings.shouldAutotrackUIEvents;
    self.shouldAutotrackViews = settings.shouldAutotrackViews;
    
    self.status = TEALPublishSettingsStatusLoadedArchive;
    
}


#pragma mark - Update Remote Mobile Publish Settings

- (void) updateWithRawSettings:(NSDictionary *)rawPublishSettings {
    
    self.mpsVersion = [TEALSystemHelpers mpsVersionNumber];
    
    // TODO: Update to look for acceptable MPS Versions
    if (!self.mpsVersion) {
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
        self.shouldAutotrackUIEvents = [uiAutotrackingEnabled boolValue];
        self.shouldAutotrackViews = [uiAutotrackingEnabled boolValue];
    }
}

// Stubs for MPS 5.0
- (void) storeUIEventsAutotrackingEnabledFromSettings:(NSDictionary *)settings {

}

- (void) storeViewsAutotrackingEnabledFromSettings:(NSDictionary *)settings {

}
@end
