//
//  TEALLifecycleConstants.m
//  Tealium
//
//  Created by Jason Koo on 9/14/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALLifecycleConstants.h"

@implementation TEALLifecycleConstants

NSString * const firstLaunchDate =      @"fLaunchDate";
NSString * const firstLaunchVersion =   @"fLaunchVersion";
NSString * const firstLaunchLibVersion = @"fVersion";

NSString * const recentUpdateDate =     @"rUpdateDate";
NSString * const recentWakeDate =       @"rWakeDate";
NSString * const recentLaunchDate =     @"rLaunchDate";
NSString * const recentSleepDate =      @"rSleepDate";
NSString * const recentTerminateDate =  @"rTerminateDate";
NSString * const recentCrashDate =      @"rCrashDate";   // TODO REMOVE: unused

NSString * const recentVersion =        @"rVersion";    // app bundle version
NSString * const recentWakeCount =      @"rWakeCount";
NSString * const recentLaunchCount =    @"rLaunchCount";
NSString * const recentSleepCount =     @"rSleepCount";
NSString * const recentTerminateCount = @"rTerminateCount";
NSString * const recentCrashCount =     @"rCrashCount";  // TODO REMOVE: using NSUserDefaults instead

NSString * const priorSecondsAwake =    @"pSecondsAwake";

NSString * const totalWakeCount =       @"tWakeCount";
NSString * const totalLaunchCount =     @"tLaunchCount";
NSString * const totalSleepCount =      @"tSleepCount";
NSString * const totalTerminateCount =  @"tTerminateCount";
NSString * const totalCrashCount =      @"tCrashCount";
NSString * const totalSecondsAwake =    @"tSecondsAwake";


@end
