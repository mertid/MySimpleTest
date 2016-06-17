//
//  Tealium+Integrations.h
//  TealiumiOS
//
//  Created by Jason Koo on 12/1/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "Tealium.h"

@interface Tealium(Integrations)

- (void) integrateWithFramework:(id)framework name:(NSString*)frameworkName;

@end
