//
//  TEALPublishSettings.h
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Status of remote publish settings
 */
typedef NS_ENUM(NSUInteger, TEALPublishSettingsStatus) {
    /**
     *  Default - no remote or saved remote version available.
     */
    TEALPublishSettingsStatusDefault,
    /**
     *  Newly pulled from the remote location.
     */
    TEALPublishSettingsStatusLoadedRemote,
    /**
     *  Unarchived from storage - last new remote settings found.
     */
    TEALPublishSettingsStatusLoadedArchive,
    /**
     *  Publish settings requests library disable.
     */
    TEALPublishSettingsStatusDisable,
};

@interface TEALPublishSettings : NSObject <NSSecureCoding>

@property (nonatomic) TEALPublishSettingsStatus status;
@property (nonatomic) NSString * _Nonnull targetVersion;
@property (nonatomic) NSString * _Nonnull url;

+ (NSDictionary * _Nullable) mobilePublishSettingsFromJSONFile:(NSData * _Nullable)data
                                                         error:(NSError * __autoreleasing _Nullable)error;

+ (NSDictionary * _Nullable) mobilePublishSettingsFromHTMLData:(NSData * _Nullable)data
                                                         error:(NSError * __autoreleasing _Nullable)error;

+ (TEALPublishSettings * _Nonnull) defaultPublishSettingsForURLString:(NSString * _Nonnull)url;

- (instancetype _Nullable) initWithURLString: (NSString * _Nonnull)url;

- (NSDictionary * _Nullable) currentPublishSettingsFromRawPublishSettings:(NSDictionary * _Nullable) rawPublishSettings;

- (BOOL) enableLowBatterySuppress;

- (BOOL) enableSendWifiOnly;

- (BOOL) disableLibrary;

- (double) minutesBetweenRefresh;

- (double) numberOfDaysDispatchesAreValid;

- (NSString * _Nullable) overrideLogLevel;

- (NSUInteger) dispatchSize;

- (NSUInteger) offlineDispatchQueueSize;

- (BOOL) isEqualToPublishSettings:(TEALPublishSettings * _Nonnull)otherPublishSettings;

- (BOOL) isEqualToRawPublishSettings:(NSDictionary * _Nonnull)publishSetting;

- (void) updateWithMatchingVersionSettings:(NSDictionary * _Nonnull)publishSettings;

+ (void) purgeAllArchives;

@end
