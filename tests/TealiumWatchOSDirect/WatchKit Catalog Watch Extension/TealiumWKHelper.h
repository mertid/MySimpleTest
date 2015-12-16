//
//  TealiumHelper.h
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TEALWKExtension.h"

/*
 *  Using an abstract class like this is the recommended best practice for 
 *  utilizing analytics or other third party libraries requiring an event 
 *  trigger with optional data.
 */
@interface TealiumWKHelper : NSObject <NSURLSessionDelegate>


/**
 *
 */
+ (void) startTracking;


/**
 *  Maps to Tealium's trackEventWithTitle:dataSources: call.
 *
 *  @param title An NSString identifier for the view change event.
 *  @param customDataSources Optional Dictionary of additional data to send with call.
 */
+ (void) trackEventWithTitle:(NSString *)title
                 dataSources:(NSDictionary *)customDataSources;

/**
 *  Maps to Tealium's trackViewWithTitle:dataSources: call.
 *  
 *  @param title An NSString identifier for the view change event.
 *  @param customDataSources Optional Dictionary of additional data to send with call.
 */
+ (void) trackViewWithTitle:(NSString *)title
                dataSources:(NSDictionary *)customDataSources;


@end
