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

- (instancetype) initWithInstanceID:(NSString *)instanceId;
- (NSString *) instanceIDCopy;
- (TEALPublishSettings *) unarchivePublishSettings;
- (void) archivePublishSettings:(TEALPublishSettings *)settings;

@end
