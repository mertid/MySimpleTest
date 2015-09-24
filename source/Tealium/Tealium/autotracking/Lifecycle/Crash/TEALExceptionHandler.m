//
//  TEALExceptionHandler.m
//  Tealium
//
//  Created by Jason Koo on 9/16/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALExceptionHandler.h"
#import "TEALDataSourceConstants.h"
#import "TEALExceptionEvents.h"

NSString * const TEALKeyExceptionHandler = @"com.tealium.exceptionhandler";

static TEALExceptionEvents *staticExceptionEvents;

@implementation TEALExceptionHandler

+ (void) enableWithProcessingBlock:(TEALDictionaryCompletionBlock)block {
    

    if ([[TEALExceptionHandler exceptionEvents] hasLastException]) {

        if (block) {
        
            block([[staticExceptionEvents dataSources] copy], nil);

        }
        
        [staticExceptionEvents resetLastExceptionInfo];
        
        [TEALExceptionHandler saveExceptionData];

    }
    
    NSSetUncaughtExceptionHandler(&TEALException);
}

+ (void) disable {
    NSSetUncaughtExceptionHandler(nil);
}

+ (TEALExceptionEvents *) exceptionEvents {
    
    if (!staticExceptionEvents) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        id exceptionData = [defaults objectForKey:TEALKeyExceptionHandler];
        
        staticExceptionEvents = [[TEALExceptionEvents alloc] init];
        [staticExceptionEvents loadFromDictionary:exceptionData];
    }
    
    return staticExceptionEvents;

}

+ (void) saveExceptionData {
    
    NSDictionary *exceptionEventsData = [staticExceptionEvents dataSources];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:exceptionEventsData forKey:TEALKeyExceptionHandler];
    
    [defaults synchronize];
}

@end

void TEALException(NSException *exception) {
    

    [staticExceptionEvents updateLastException:exception];
    
    [staticExceptionEvents addEvent];
    
    [TEALExceptionHandler saveExceptionData];
    
}

//void TEALException(NSException *exception) {
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    NSData *exceptionData = [NSKeyedArchiver archivedDataWithRootObject:exception];
//    
//    [defaults setObject:exceptionData forKey:TEALKeyExceptionHandler];
//    
//    NSArray *stackTrace = exception.callStackSymbols;
//    
//    if (stackTrace) {
//        NSString *stackTraceStringValue = [NSString stringWithFormat:@"%@", stackTrace];
//        
//        [defaults setObject:stackTraceStringValue forKey:TEALDataSourceKey_ExceptionTrace];
//    }
//    // update exception count
//    
//#warning Update with actual constant
//    
//    NSNumber *currentCrashCount = [defaults objectForKey:@"crash_count"];
//    NSNumber *newCurrentCrashCount = @([currentCrashCount intValue] + 1);
//    
//#warning Update with actual constants
//
//    [defaults setObject:newCurrentCrashCount forKey:@"crash_count"];
//    
//    NSNumber *totalCrashCount = [defaults objectForKey:@"total_crash_count"];
//    NSNumber *newTotalCrashCount = @([totalCrashCount intValue] + 1);
//    
//    [defaults setObject:newTotalCrashCount forKey:@"total_crash_count"];
//    
//    // force IO
//    [defaults synchronize];
//    
//}