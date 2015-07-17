//
//  Tealium Mobile LibraryAPIHelpers.h
//  Tealium Mobile Library
//
//  Created by George Webster on 4/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEALSettings;

@interface TEALAPIHelpers : NSObject

#pragma mark - Get Data

// TODO: possibly change to visitorProfileURL... or subclass a TEALCollectAPIHelpers
+ (NSURL *) profileURLFromSettings:(TEALSettings *)settings;
+ (NSURL *) profileDefinitionsURLFromSettings:(TEALSettings *)settings;

#pragma mark - Send Data

+ (NSString *) sendDataURLStringFromSettings:(TEALSettings *)settings;

#pragma MPS / Mobile Publish Settings Helpers

+ (NSString *) mobileHTMLURLStringFromSettings:(TEALSettings *)settings;
+ (NSString *) mobilePublishSettingsURLStringFromSettings:(TEALSettings *)settings;

@end
