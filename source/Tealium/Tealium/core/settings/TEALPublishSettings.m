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
#import "NSString+Tealium.h"
#import "TEALPublishSettingsStore.h"
#import "TEALSystemHelpers.h"
#import "TEALError.h"

@interface TEALPublishSettings()

@property (nonatomic, strong) TEALPublishSettingsStore *store;
@property (copy, nonatomic) NSString *mpsVersionCopy;

@end

@implementation TEALPublishSettings

#pragma mark - PRIVATE

+ (BOOL) supportsSecureCoding {
    return YES;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
        
        _url                            = [aDecoder decodeObjectForKey:@"url"];
//        _mpsVersion                     = [aDecoder decodeObjectForKey:@"mpsVersion"];
        _numberOfDaysDispatchesAreValid = [aDecoder decodeIntegerForKey:@"numberOfDaysDispatchesAreValid"];
        _dispatchSize                   = [aDecoder decodeIntegerForKey:@"dispatchSize"];
        _offlineDispatchQueueSize       = [aDecoder decodeIntegerForKey:@"offlineDispatchQueueSize"];
        _enableLowBatterySuppress       = [aDecoder decodeBoolForKey:@"shouldLowBatterySuppress"];
        _enableSendWifiOnly             = [aDecoder decodeBoolForKey:@"shouldSendWifiOnly"];
        
        _enableAudienceStream           = [aDecoder decodeBoolForKey:@"enableAudienceStream"];
        _enableTagManagement            = [aDecoder decodeBoolForKey:@"enableTagManagment"];
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
//    [aCoder encodeObject:self.mpsVersion forKey:@"mpsVersion"];
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

- (BOOL) isEqual:(id)object {
    
    if (![object isKindOfClass:([TEALPublishSettings class])]) {
        return NO;
    }
    
    TEALPublishSettings *otherSettings = object;
    
    if (![otherSettings.url isEqualToString:self.url]) return  NO;
//    if (![otherSettings.mpsVersion isEqualToString:self.mpsVersion]) return  NO;
    if (otherSettings.dispatchSize != self.dispatchSize) return  NO;
    if (otherSettings.offlineDispatchQueueSize != self.offlineDispatchQueueSize) return  NO;
    if (otherSettings.numberOfDaysDispatchesAreValid != self.numberOfDaysDispatchesAreValid) return  NO;
    if (otherSettings.enableLowBatterySuppress != self.enableLowBatterySuppress) return  NO;
    if (otherSettings.enableSendWifiOnly != self.enableSendWifiOnly) return  NO;

    
    return YES;
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
        // No longer a TIQ option
    }
}

- (void) storeAudienceStreamSettingFromSettings:(NSDictionary *)settings {
    
    NSString *audiencestream = settings[@"audiencestream"];
    
    if (audiencestream) {
        self.enableAudienceStream = [audiencestream boolValue];
    }
}

- (void) storeTagManagmentSettingFromSettings:(NSDictionary *)settings {
    
    NSString *tagmanagement = settings[@"tag_management"];
    
    if (tagmanagement) {
        self.enableTagManagement = [tagmanagement boolValue];
    }
}

- (NSString *) description {
    
    NSDictionary *descriptionDictionary = @{
                                            @"status":[NSString stringWithFormat:@"%lu", (unsigned long)self.status],
                                            @"url":[NSString teal_dictionarySafeString:self.url],
                                            @"mps version":[NSString teal_dictionarySafeString:self.mpsVersion],
                                            @"dispatch size":[NSString stringWithFormat:@"%i", (int)self.dispatchSize],
                                            @"offline dispatch size":[NSString stringWithFormat:@"%i", (int)self.offlineDispatchQueueSize],
                                            @"number of day dispatches valid":[NSString stringWithFormat:@"%i",(int)self.numberOfDaysDispatchesAreValid],
                                            @"battery save mode":[NSString teal_stringFromBool:self.enableLowBatterySuppress],
                                            @"wifi only mode":[NSString teal_stringFromBool:self.enableSendWifiOnly],
                                            @"enable AudienceStream":[NSString teal_stringFromBool:self.enableAudienceStream],
                                            @"enable Tag Management":[NSString teal_stringFromBool:self.enableTagManagement]
                                            };
    
    return [NSString teal_descriptionForObject:self fromDictionary:descriptionDictionary];
}
#pragma mark - PUBLIC

- (instancetype) initWithURLString:(NSString *)url {
    self = [super init];
    
    if (self) {
        
        // Default Remote Settings
        _url                            = url;
        _status                         = TEALPublishSettingsStatusDefault;
//        _mpsVersion                     = [TEALSystemHelpers tealiumIQlibraryVersion];
        _numberOfDaysDispatchesAreValid = -1;
        _dispatchSize                   = 1;
        _offlineDispatchQueueSize       = 1000; // -1 is supposed to be inf. but yeah thats alot
        _enableLowBatterySuppress       = YES;
        _enableSendWifiOnly             = NO;
        _enableAudienceStream           = YES;
        _enableTagManagement            = NO;
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
    
    TEAL_LogVerbose(@"Updating publish settings: %@", settings);

    [self storeDispatchSizeFromSettings:settings];
    [self storeOfflineDispatchQueueSizeFromSettings:settings];
    [self storeDispatchExpirationFromSettings:settings];
    [self storeLowBatterySuppressionFromSettings:settings];
    [self storeWifiOnlySettingFromSettings:settings];
    [self storeUIAutotrackingEnabledFromSettings:settings];
    [self storeAudienceStreamSettingFromSettings:settings];
    [self storeTagManagmentSettingFromSettings:settings];
    
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
                                 TEAL_LogVerbose(@"text checking result: %@", result);
                             }
                             
                             if (result.range.location != NSNotFound) {
                                 scriptContents = [dataString substringWithRange:result.range];
                                 
                                 if (scriptContents) {
                                     TEAL_LogVerbose(@"scriptContents: %@", scriptContents);
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
        
        TEAL_LogVerbose(@"mobile publish settings not found! old mobile library extension is not supported.  ");
        
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
    
    TEAL_LogVerbose(@"mpsDataString: %@", mpsDataString);
    
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


@end
