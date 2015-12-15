//
//  TEALPublishSettingsStore.h
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEALPublishSettings;

@interface TEALPublishSettingsStore : NSObject

+ (TEALPublishSettings *) unarchivePublishSettingsForInstanceID:(NSString *)instanceID;

+ (void) archivePublishSettings:(TEALPublishSettings *)settings;

@end
