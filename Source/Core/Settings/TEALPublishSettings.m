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
                                                       options:NSJSONReadingAllowFragments
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
    
    if (![[self publishSettingsData] isEqualToDictionary:[otherPublishSettings publishSettingsData]]) return NO;
    
    if (self.status != otherPublishSettings.status) return NO;
    
    if (![self.url isEqualToString:otherPublishSettings.url]) return NO;
    
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

    [TEALPublishSettingsStore archivePublishSettings:self];
    
}

- (BOOL) enableLowBatterySuppress {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyLowBatteryMode];
    
    if (![number respondsToSelector:@selector(boolValue)]){
        return NO;
    }
    
    return [number boolValue];
    
}

- (BOOL) enableSendWifiOnly {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyWifiOnlyMode];
    
    if (![number respondsToSelector:@selector(boolValue)]){
        return NO;
    }
    
    return [number boolValue];
    
}

- (BOOL) disableLibrary {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyIsEnabled];
    
    if (![number respondsToSelector:@selector(boolValue)]){
        return NO;
    }
    
    return [number boolValue];
}

- (double) minutesBetweenRefresh {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyMinutesBetweenRefresh];
    
    if (![number respondsToSelector:@selector(doubleValue)]){
        return NO;
    }
    
    return [number doubleValue];
    
}

- (double) numberOfDaysDispatchesAreValid {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyDispatchExpiration];
    
    if (![number respondsToSelector:@selector(doubleValue)]){
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
    
    if (![number respondsToSelector:@selector(integerValue)]){
        return 0;
    }
    
    return [number integerValue];
}

- (NSUInteger) offlineDispatchQueueSize {
    
    NSNumber *number = [self publishSettingsData][TEALPublishSettingKeyOfflineDispatchSize];
    
    if (![number respondsToSelector:@selector(integerValue)]){
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
