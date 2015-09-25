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
    
#warning Get current uncaughtExceptionHandler and chain?
    
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