//
//  TEALLifecycle+PrivateHeader.h
//  UIKitCatalog
//
//  Created by Jason Koo on 2/29/16.
//  Copyright © 2016 f. All rights reserved.
//
//  For Testing

#import "Tealium+Lifecycle.h"

@interface Tealium (LifecyclePrivate)

- (void) executeLifecycleCommandForType:(TEALLifecycleType)type
                           overrideDate:(NSDate* _Nonnull)date
                            autoTracked:(BOOL)autoTracked;

- (void) resetLifecycleData;

- (NSDictionary * _Nonnull) newLifecycleDataSourcesForType:(TEALLifecycleType)type
                                                      date:(NSDate * _Nullable)date
                                            persistentData:(NSDictionary * _Nonnull)persistentData;

- (NSDictionary * _Nonnull) updatePersistentDataSourcesForType:(TEALLifecycleType)type
                                                          date:(NSDate* _Nonnull)date
                                                persistentData:(NSDictionary* _Nonnull)persistentData;

+ (TEALLifecycleType)lifecycleTypeFromString:(NSString * _Nullable)string;


@end