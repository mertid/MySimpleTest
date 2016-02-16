//
//  UIColor+TealiumAdditions.m
//  TealiumUtilities
//
//  Created by Jason Koo & George Webster
//  Copyright (c) 2014 tealium. All rights reserved.
//

#import "UIColor+TEALMobileCompanion.h"

@implementation UIColor (TEALMobileCompanion)

+ (UIColor *) teal_blue {
    return [UIColor colorWithRed:(54.0/255.0) green:(141.0/255.0) blue:(212.0/255.0) alpha:1.0];
}

+ (UIColor *) teal_darkGrey {
    const float color = .2509;
    return [UIColor colorWithRed:color green:color blue:color alpha:1.0];
}

+ (UIColor *) teal_liteGrey {
    const float liteGrey = .5019;
    return [UIColor colorWithRed:liteGrey green:liteGrey blue:liteGrey alpha:1.0];
}

+ (UIColor *) teal_midGrey {
    const float color = .4;
    return [UIColor colorWithRed:color green:color blue:color alpha:1.0];
}

+ (UIColor *) teal_superLiteGrey {
    const float color = .8;
    return [UIColor colorWithRed:color green:color blue:color alpha:1.0];
}

@end
