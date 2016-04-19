//
//  Tealium+Integrations.m
//  TealiumiOS
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "Tealium+Integrations.h"

@implementation Tealium (Integrations)

static NSMapTable *frameworks;

- (void) integrateWithFramework:(id)framework
                           name:(NSString*)frameworkName{
    
    [self integratedFrameworks][frameworkName] = framework;
    
}

- (NSMapTable *) integratedFrameworks {
    
    if (!frameworks){
        frameworks = [[NSMapTable alloc] init];
    }
    
    return frameworks;
    
}

@end
