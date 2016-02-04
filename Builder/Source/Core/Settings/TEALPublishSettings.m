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
#import "TEALVersion.h"

NSString * const TEALPublishSettingKeyData = @"com.tealium.publishsetting.data";
NSString * const TEALPublishSettingKeyModuleDescriptionData = @"module_description_data";

@interface TEALPublishSettings()

@property (nonatomic) NSMutableDictionary *privatePublishSettingsData;
@property (nonatomic) dispatch_queue_t privateQueue;
@property (nonatomic) NSString *instanceID;

@end


@implementation TEALPublishSettings

#pragma mark - PUBLIC CLASS

+ (NSDictionary *) mobilePublishSettingsFromJSONFile:(NSData *)data error:(NSError  * __autoreleasing *)error {
    
    if (!data){
        *error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"Publish Settings from JSON file failed.", @"")
                                  reason:NSLocalizedString(@"Data argument missing.", @"")
                              suggestion:NSLocalizedString(@"Double check sourse JSON file.", @"")];
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

+ (NSDictionary *) mobilePublishSettingsFromHTMLData:(NSData *)data error:(NSError * __autoreleasing *)error {
    
    if (!data){
        *error = [TEALError errorWithCode:TEALErrorCodeMalformed
                             description:NSLocalizedString(@"Publish Settings from HTML file failed.", @"")
                                  reason:NSLocalizedString(@"Data argument missing.", @"")
                              suggestion:NSLocalizedString(@"Double check sourse JSON file.", @"")];
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
                             
#warning this script will break if an additional var is added by the publishing engine
                             
                             if (result.range.location != NSNotFound) {
                                 scriptContents = [dataString substringWithRange:result.range];
                                 
                                 *stop = YES;
                             }
                         }];
    
    if (!scriptContents) {
        *error = [TEALError errorWithCode:TEALErrorCodeException
                             description:NSLocalizedString(@"Publish Settings from HTML file failed.", @"")
                                  reason:NSLocalizedString(@"Contents not found.", @"")
                              suggestion:NSLocalizedString(@"Double check sourse HTML file.", @"")];
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
        *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                             description:@"Mobile publish settings not found."
                                  reason:@"End of publish settings data not found after parsing mobile.html"
                              suggestion:@"Please enable mobile publish settings in Tealium iQ."];
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

+ (NSDictionary *) currentPublishSettingsFromRawPublishSettings:(NSDictionary *) rawPublishSettings {
    
    NSUInteger versionNumberStripped = [TEALLibraryVersion integerValue];
    
    NSString *targetVersion = [NSString stringWithFormat:@"%lu", versionNumberStripped];
    
    return rawPublishSettings[targetVersion];
    
}

+ (instancetype) archivedPublishSettingForURL:(NSString *)url {
    
    if (!url){
        return nil;
    }
    
    TEALPublishSettings *archivedSettings = [TEALPublishSettingsStore unarchivePublishSettingsForInstanceID:url];
    
    if (![archivedSettings isKindOfClass:[TEALPublishSettings class]]){
        return nil;
    }
    
    return archivedSettings;
    
}

+ (TEALPublishSettings *) unarchivePublishSettingsForInstanceID:(NSString *)instanceID {
    return [TEALPublishSettingsStore unarchivePublishSettingsForInstanceID:instanceID];
}

+ (TEALPublishSettings * _Nonnull) defaultPublishSettingsForURLString:(NSString * _Nonnull)url {
    
    TEALPublishSettings *defaultPublishSettings = [[TEALPublishSettings alloc] initDefaultSettingsForURLString:url];
    
    return defaultPublishSettings;
}

#pragma mark - PRIVATE CLASS

+ (NSDictionary *) defaultPublishSettingsData {
    
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

+ (BOOL) supportsSecureCoding {
    return YES;
}

#pragma mark - PUBLIC

- (instancetype) initWithURLString:(NSString *)url {
    
    if (!url) {
        return nil;
    }
        
    return [TEALPublishSettings defaultPublishSettingsForURLString:url];
        
}

- (instancetype) initDefaultSettingsForURLString:(NSString *)url {
    
    self = [super init];
    
    if (self) {
        
        _privatePublishSettingsData = [NSMutableDictionary dictionaryWithDictionary:[TEALPublishSettings defaultPublishSettingsData]];
        _status                         = TEALPublishSettingsStatusDefault;
        _url                            = url;
        
    }
    return self;
}

- (BOOL) isEqualToPublishSettings:(TEALPublishSettings *)otherPublishSettings {
    
    if (![[self publishSettingsData] isEqualToDictionary:[otherPublishSettings publishSettingsData]]) return NO;
        
    if (self.url &&
        otherPublishSettings.url &&
        ![self.url isEqualToString:otherPublishSettings.url]) return NO;
    
    return YES;
}

- (BOOL) isEqualToRawPublishSettings:(NSDictionary *)publishSetting {
    
    return [publishSetting isEqualToDictionary:self.privatePublishSettingsData];
   
}

- (void) updateWithMatchingVersionSettings:(NSDictionary *)publishSettings {
    
    [self importLocalSettingsFromMatchingVersionSettings:publishSettings];
    
    [TEALPublishSettingsStore archivePublishSettings:self];
    
}

- (BOOL) enableLowBatterySuppress {
    
    NSString *number = [self publishSettingsData][TEALPublishSettingKeyLowBatteryMode];
    
    if (!number ||
        ![number respondsToSelector:@selector(boolValue)]){
        return false;
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
    
    NSString *enable = [self publishSettingsData][TEALPublishSettingKeyIsEnabled];
    
    if (![enable respondsToSelector:@selector(boolValue)]){
        return NO;
    }
    
    // This is somewhat awful
    
    return ![enable boolValue];
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
    
    if ([string isEqualToString:@""]){
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

+ (void) purgeAllArchives {
    
    [TEALPublishSettingsStore purgeAllPublishSettings];
    
}

#pragma mark - PRIVATE

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [self init];
    
    if (self) {
        
        _privatePublishSettingsData = [aDecoder decodeObjectForKey:TEALPublishSettingKeyData];
        
        TEALPublishSettingsStatus status = [aDecoder decodeIntegerForKey:@"status"];
        if (status == TEALPublishSettingsStatusLoadedRemote) {
            status = TEALPublishSettingsStatusLoadedArchive;
        }
        
        _url = [aDecoder decodeObjectForKey:@"url"];
        
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
    
    [aCoder encodeObject:self.url forKey:@"url"];
    
//    [aCoder encodeObject:TEALLibraryVersion forKey:@"targetVersion"];
    
    [aCoder encodeObject:[self publishSettingsData] forKey:TEALPublishSettingKeyData];
        
}

- (void) importLocalSettingsFromMatchingVersionSettings:(NSDictionary *)settings {
    
    self.privatePublishSettingsData = [NSMutableDictionary dictionaryWithDictionary:settings];
    
    self.status = TEALPublishSettingsStatusLoadedRemote;
    
}

- (NSString *) statusAsString {
    
    NSString *statusString = nil;
    
    switch (self.status) {
        case TEALPublishSettingsStatusLoadedArchive:
            statusString = NSLocalizedString(@"archive", @"Publish Setting Archive String");
            break;
        case TEALPublishSettingsStatusLoadedRemote:
            statusString = NSLocalizedString(@"remote", @"Publish Setting Remote String");
            break;
        default:
            statusString = NSLocalizedString(@"default", @"Publish Setting Default String");
            break;
    }
    return statusString;
}

- (NSString *) description {
    
    NSMutableDictionary *description = [NSMutableDictionary dictionaryWithDictionary:[[self publishSettingsData] copy]];
    
    NSUInteger versionInt = [TEALLibraryVersion integerValue];
    
    NSString *versionAsInt = [NSString stringWithFormat:@"%lu", (unsigned long)versionInt];
    
    description[@"mps version"] = [NSString teal_dictionarySafeString:versionAsInt];
    
    description[@"url"] = [NSString teal_dictionarySafeString:self.url];
    
    NSString *descriptionHeader = [NSString stringWithFormat:@"Remote settings from %@", [self statusAsString]];

    NSString *descriptionString = [NSString teal_descriptionForObject:self
                                                          description:descriptionHeader
                                                       fromDictionary:description];
    
    return descriptionString;
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


@end
