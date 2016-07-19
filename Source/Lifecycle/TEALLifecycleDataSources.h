//
//  TEALLifecycleDataSources.h
//  UIKitCatalog
//
//  Created by Jason Koo on 2/29/16.
//  Copyright © 2016 f. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Types of Tealium lifecycle event.
 */
typedef NS_ENUM(NSUInteger, TEALLifecycleType) {
    /**
     *  No Lifecycle type assigned.
     */
    TEALLifecycleTypeNone = 0,
    /**
     *  When the app has starts for the very first time.
     */
    TEALLifecycleTypeLaunch,
    /**
     *  When the app has awoken from a paused / background state.
     */
    TEALLifecycleTypeWake,
    /**
     *  When the user has left the app or is going to the background.
     */
    TEALLifecycleTypeSleep
};

@interface TEALLifecycleDataSources : NSObject

+ (NSDictionary * _Nonnull) incrementedLifetimeValuesForKeys:(NSArray * _Nullable)keys
                                                      amount:(int)number
                                              persistentData:(NSDictionary * _Nullable)persistentData;

+ (NSDictionary * _Nonnull) newLifecycleDataSourcesForType:(TEALLifecycleType)type
                                             date:(NSDate * _Nonnull)date
                                   persistentData:(NSDictionary * _Nullable)persistentData;

+ (NSDictionary * _Nonnull) updatePersistentDataSourcesForType:(TEALLifecycleType)type
                                                 date:(NSDate* _Nonnull)date
                                       persistentData:(NSDictionary * _Nullable)persistentData;

+ (NSString * _Nonnull) stringLifecycleType:(TEALLifecycleType)type;

+ (NSString * _Nonnull) stringFromLifecyleType:(TEALLifecycleType)type;

+ (TEALLifecycleType) lifecycleTypeFromString:(NSString * _Nonnull)string;

+ (TEALLifecycleType) mostRecentDateFromPersistentData:(NSDictionary * _Nonnull)persistentData;

+ (BOOL) isFirstWakeTodayForDate:(NSDate* _Nonnull)date
                       priorDate:(NSDate* _Nullable)earlierDate;

+ (NSString* _Nonnull) dayOfWeekForDate:(NSDate* _Nonnull)date;

+ (NSString* _Nonnull) secondsFrom:(NSDate* _Nullable)earlierDate
                                to:(NSDate* _Nullable)laterDate;

+ (NSDate * _Nullable) dateFromISOString:(NSString * _Nonnull)string;

@end
