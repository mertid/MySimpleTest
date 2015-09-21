//
//  TEALExceptionHandler.m
//  Tealium
//
//  Created by Jason Koo on 9/16/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALExceptionHandler.h"
#import "TEALDataSourceConstants.h"

NSString * const TEALKeyExceptionHandler = @"com.tealium.exceptionhandler";

@implementation TEALExceptionHandler

+ (void) enable {
    NSSetUncaughtExceptionHandler(&TEALException);
}

+ (void) disable {
    NSSetUncaughtExceptionHandler(nil);
}



@end

#warning Move to autotracking module?


void TEALException(NSException *exception) {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *exceptionData = [NSKeyedArchiver archivedDataWithRootObject:exception];
    
    [defaults setObject:exceptionData forKey:TEALKeyExceptionHandler];
    
    NSArray *stackTrace = exception.callStackSymbols;
    
    if (stackTrace) {
        NSString *stackTraceStringValue = [NSString stringWithFormat:@"%@", stackTrace];
        
        [defaults setObject:stackTraceStringValue forKey:TEALDataSourceKey_ExceptionTrace];
    }
    // update exception count
    
#warning Update with actual constant
    
    NSNumber *currentCrashCount = [defaults objectForKey:@"crash_count"];
    NSNumber *newCurrentCrashCount = @([currentCrashCount intValue] + 1);
    
#warning Update with actual constants

    [defaults setObject:newCurrentCrashCount forKey:@"crash_count"];
    
    NSNumber *totalCrashCount = [defaults objectForKey:@"total_crash_count"];
    NSNumber *newTotalCrashCount = @([totalCrashCount intValue] + 1);
    
    [defaults setObject:newTotalCrashCount forKey:@"total_crash_count"];
    
    // force IO
    [defaults synchronize];
    
}