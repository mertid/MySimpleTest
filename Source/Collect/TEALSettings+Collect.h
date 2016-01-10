//
//  TEALSettings+Collect.h
//  UIKitCatalog
//
//  Created by Jason Koo on 1/9/16.
//
//

#import "TEALSettings.h"

@interface TEALSettings (Collect)

- (BOOL) collectEnabled;

- (BOOL) s2SLegacyEnabled;

- (NSUInteger) pollingFrequency;

- (NSString * _Nullable) collectDispatchURLString;

- (NSString * _Nullable) s2SLegacyDispatchURLString;

@end
