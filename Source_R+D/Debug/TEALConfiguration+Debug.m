//
//  TEALConfiguration+Debug.m
//  FrameworkBuilder
//
//  Created by Jason Koo on 9/29/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

#import "TEALConfiguration+Debug.h"
#import "TEALConfiguration+PrivateHeader.h"

NSString * const TEALDebugEnableKey = @"com.tealium.lifecycleautotracking.enable";

@implementation TEALConfiguration (Debug)

#pragma mark - PUBLIC

- (BOOL) isDebugEnabled {
    
    NSDictionary *moduleData =  [self moduleData];
    
    id enable = moduleData[TEALDebugEnableKey];
    
    if (!enable ||
        ![enable respondsToSelector:@selector(boolValue)]){
        
        return NO;
        
    }
    
    return  [enable boolValue];
}

- (void) setDebugEnabled:(BOOL)enable {
    
    [self setModuleObject:@(enable)
                   forKey:TEALDebugEnableKey
               completion:nil];
    
    [self setModuleDescription:enable?@"YES":@"NO" forKey:@"Debug enabled"];
    
}


@end
