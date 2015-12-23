//
//  TEALDispatch+PrivateHeader.h
//  Tealium
//
//  Created by Jason Koo on 11/9/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#ifndef TEALDispatch_PrivateHeader_h
#define TEALDispatch_PrivateHeader_h

#endif /* TEALDispatch_PrivateHeader_h */

#import "TEALDispatch.h"

@interface TEALDispatch (Private)

+ (TEALDispatch *) dispatchForType:(TEALDispatchType)dispatchType withPayload:(NSDictionary *)payload;

+ (NSString *) stringFromDispatchType:(TEALDispatchType)dispatchType;

- (void) queue:(BOOL)wasQueued;

@end
