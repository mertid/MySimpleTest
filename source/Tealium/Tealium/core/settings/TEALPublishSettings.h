//
//  TEALPublishSettings.h
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TEALPublishSettingsStatus) {
    TEALPublishSettingsStatusDefault,
    TEALPublishSettingsStatusLoadedRemote,
    TEALPublishSettingsStatusLoadedArchive,
    TEALPublishSettingsStatusDisable,
    TEALPublishSettingsStatusUnchanged
};

@interface TEALPublishSettings : NSObject <NSSecureCoding>

@property (nonatomic) TEALPublishSettingsStatus status;
@property (nonatomic) NSString *url;
@property (nonatomic) NSUInteger dispatchSize; // batching
@property (nonatomic) NSUInteger offlineDispatchQueueSize;
@property (nonatomic) double minutesBetweenRefresh;
@property (nonatomic) double numberOfDaysDispatchesAreValid;
@property (nonatomic) BOOL enableLowBatterySuppress;
@property (nonatomic) BOOL enableSendWifiOnly;
@property (nonatomic) BOOL enableAudienceStream;
@property (nonatomic) BOOL enableTagManagement;

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

- (instancetype) initWithURLString:(NSString *)url;

- (BOOL) areValidRawPublishSettings:(NSDictionary *) rawPublishSettings;
- (BOOL) isEqualToPublishSettings:(TEALPublishSettings *)otherPublishSettings;
- (BOOL) areNewRawPublishSettings:(NSDictionary *)rawPublishSettings;
- (void) updateWithRawSettings:(NSDictionary *)rawPublishSettings;
- (void) loadArchived;
//- (NSString *) mpsVersion;
- (NSDictionary *) mobilePublishSettingsFromHTMLData:(NSData *)data error:(NSError **)error;

@end
