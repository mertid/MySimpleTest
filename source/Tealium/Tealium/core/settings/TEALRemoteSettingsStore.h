//
//  TEALSettingsStore.h
//  Tealium Mobile Library
//
//  Created by George Webster on 12/29/14.
//  Copyright (c) 2014 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TEALSystemProtocols.h"

@class TEALRemoteSettings;
@class TEALURLSessionManager;
@class TEALConfiguration;
@class TEALOperationManager;


typedef void (^TEALSettingsCompletionBlock)(TEALRemoteSettings *settings, NSError *error);

@protocol TEALRemoteSettingsStoreConfiguration <NSObject, TEALOperations, TEALURLSessions>

- (NSString *) mobilePublishSettingsURLStringForSettings:(TEALRemoteSettings *)settings;
- (NSDictionary *) mobilePublishSettingsURLParams;

@end

@interface TEALRemoteSettingsStore : NSObject

@property (readonly, nonatomic) TEALRemoteSettings *currentSettings;
@property (weak, nonatomic) id<TEALRemoteSettingsStoreConfiguration> configuration;

- (instancetype) initWithConfiguration:(id<TEALRemoteSettingsStoreConfiguration>)configuration;

- (TEALRemoteSettings *) settingsFromConfiguration:(TEALConfiguration *)configuration visitorID:(NSString *)visitorID;

- (void) unarchiveCurrentSettings;
- (void) archiveCurrentSettings;

- (void) fetchRemoteSettingsWithSetting:(TEALRemoteSettings *)settings
                             completion:(TEALSettingsCompletionBlock)completion;


@end
