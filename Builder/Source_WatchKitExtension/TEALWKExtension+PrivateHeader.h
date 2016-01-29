//
//  TEALWKExtension+PrivateHeader.h
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/16/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TEALWKExtension.h"
#import "TEALDataQueue+PrivateHeader.h"

@interface TEALWKExtension(Private)

@property TEALDataQueue * _Nonnull queue;

+ (instancetype _Nullable) newInstanceForKey:(NSString * _Nonnull)key
                               configuration:(TEALWKExtensionConfiguration * _Nonnull)configuration
                                  completion:(void(^ _Nullable)(BOOL success, NSError * _Nullable error))completion;

- (void) trackEventWithTitle:(NSString * _Nonnull)title
                 dataSources:(NSDictionary * _Nullable)customDataSources
                  completion:(void(^ _Nullable)(BOOL success, NSError * _Nullable error))completion;

- (void) trackViewWithTitle:(NSString * _Nonnull)title
                 dataSources:(NSDictionary * _Nullable)customDataSources
                  completion:(void(^ _Nullable)(BOOL success, NSError * _Nullable error))completion;

@end
