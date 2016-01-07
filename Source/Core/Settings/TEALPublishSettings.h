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

/**
 *
 */
//extern NSString * const TEALPublishSettingKeyIsEnabled;

@interface TEALPublishSettings : NSObject <NSSecureCoding>

@property (nonatomic) TEALPublishSettingsStatus status;
@property (nonatomic) NSString * _Nonnull url;
@property (nonatomic) NSUInteger dispatchSize; // batching
@property (nonatomic) NSUInteger offlineDispatchQueueSize;
@property (nonatomic) NSString * _Nonnull publishSettingsVersion;
@property (nonatomic) NSString * _Nullable overrideLogLevel;
@property (nonatomic) double minutesBetweenRefresh;
@property (nonatomic) double numberOfDaysDispatchesAreValid;
@property (nonatomic) BOOL enableLowBatterySuppress;
@property (nonatomic) BOOL enableSendWifiOnly;
@property (nonatomic) BOOL enableCollect;
@property (nonatomic) BOOL enableS2SLegacy;
@property (nonatomic) BOOL enableTagManagement;

@property (nonatomic) BOOL disableLibrary;
@property (nonatomic) BOOL disableApplicationInfoAutotracking;
@property (nonatomic) BOOL disableCarrierInfoAutotracking;
@property (nonatomic) BOOL disableCrashAutotracking;
@property (nonatomic) BOOL disableDeviceInfoAutotracking;
@property (nonatomic) BOOL disableUIEventAutotracking;
@property (nonatomic) BOOL disableViewAutotracking;
@property (nonatomic) BOOL disableiVarAutotracking;
@property (nonatomic) BOOL disableLifecycleAutotracking;
@property (nonatomic) BOOL disableTimestampAutotracking;
@property (nonatomic) BOOL disableMobileCompanion;

+ (NSDictionary * _Nullable) mobilePublishSettingsFromJSONFile:(NSData * _Nullable)data error:(NSError * _Nullable __autoreleasing * _Nullable)error;
+ (NSDictionary * _Nullable) mobilePublishSettingsFromHTMLData:(NSData * _Nullable)data error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (instancetype _Nullable) initWithURLString: (NSString * _Nonnull)url;

- (BOOL) correctMPSVersionRawPublishSettings:(NSDictionary * _Nonnull) rawPublishSettings;
- (BOOL) isEqualToPublishSettings:(TEALPublishSettings * _Nonnull)otherPublishSettings;
- (BOOL) areNewRawPublishSettings:(NSDictionary * _Nonnull)rawPublishSettings;
- (void) updateWithRawSettings:(NSDictionary * _Nonnull)rawPublishSettings;

@end
