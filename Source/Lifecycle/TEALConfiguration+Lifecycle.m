//
//  TEALConfiguration+Lifecycle.m
//
//  Created by Jason Koo on 7/18/16.
//
//

#import "TEALConfiguration+Lifecycle.h"
#import "TEALConfiguration+PrivateHeader.h"

NSString * const TEALLifecycleEnableKey = @"com.tealium.lifecycleautotracking.enable";

@implementation TEALConfiguration (Lifecycle)

#pragma mark - PUBLIC

- (BOOL) isAutotrackingLifecycleEnabled {
    
    NSDictionary *moduleData =  [self moduleData];
    
    id enable = moduleData[TEALLifecycleEnableKey];
                 
    if (!enable ||
        ![enable respondsToSelector:@selector(boolValue)]){
        
        // Default
        
        [self setAutotrackingLifecycleEnabled:YES];
        
        return YES;
        
    }
    
    return  [enable boolValue];
}

- (void) setAutotrackingLifecycleEnabled:(BOOL)enable {
    
    [self setModuleObject:@(enable)
                   forKey:TEALLifecycleEnableKey
               completion:nil];
    
    [self setModuleDescription:enable?@"YES":@"NO" forKey:@"Autotracking lifecycle enabled"];
    
}



@end
