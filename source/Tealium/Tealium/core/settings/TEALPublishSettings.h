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
    TEALPublishSettingsStatusDisable
};

@interface TEALPublishSettings : NSObject <NSSecureCoding>

@property (nonatomic) TEALPublishSettingsStatus status;
@property (nonatomic, strong) NSString *url;
@property (copy, nonatomic) NSString *mpsVersion;
@property (nonatomic) NSUInteger dispatchSize; // batching
@property (nonatomic) NSUInteger offlineDispatchQueueSize;
@property (nonatomic) NSInteger numberOfDaysDispatchesAreValid;
@property (nonatomic) BOOL enableLowBatterySuppress;
@property (nonatomic) BOOL enableSendWifiOnly;
@property (nonatomic) BOOL enableAudienceStream;
@property (nonatomic) BOOL enableTagManagement;
//@property (nonatomic) BOOL shouldAutotrackUIEvents;
//@property (nonatomic) BOOL shouldAutotrackViews;

- (instancetype) initWithURLString:(NSString *)url;

- (void) updateWithRawSettings:(NSDictionary *)rawPublishSettings;
- (void) loadArchived;

@end
