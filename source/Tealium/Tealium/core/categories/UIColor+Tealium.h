//
//  UIColor+TealiumAdditions.h
//  TealiumUtilities
//
//  Created by Jason Koo & George Webster
//  Copyright (c) 2014 tealium. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Tealium)

#warning THIS USED ANYWHERE?

+ (UIColor *) teal_colorWithHexString:(NSString *)hexString;

CGFloat TEALColorComponent(NSString *string, NSUInteger start, NSUInteger length);

@end
