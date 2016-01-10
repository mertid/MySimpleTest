//
//  TEALConfiguration+Collect.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/9/16.
//
//

#import "TEALConfiguration+Collect.h"
#import "TEALConfiguration+PrivateHeader.h"

NSString * const TEALCollectOverrideDispatchURLKey = @"com.tealium.collect.override.dispatchURL";

@implementation TEALConfiguration (Collect)

- (NSString *) overrideCollectDispatchURL {
    
    NSDictionary *moduleData =  [self moduleData];
    
    return [moduleData[TEALCollectOverrideDispatchURLKey] copy];
    
}

- (void) setOverrideCollectDispatchURL:(NSString *) overrideURL{
    
    [self setModuleObject:overrideURL forKey:TEALCollectOverrideDispatchURLKey];
    
    [self setModuleDescription:overrideURL forKey:@"override dispatch url"];
}

@end
