//
//  TEALLifecycle+PrivateTestHeader.h
//  TealiumTests
//
//  Created by Jason Koo on 10/20/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#ifndef TEALLifecycle_PrivateTestHeader_h
#define TEALLifecycle_PrivateTestHeader_h


#endif /* TEALLifecycle_PrivateTestHeader_h */

#import <Tealium/TEALLifecycle.h>

@interface TEALLifecycle (PrivateTestHeader)

- (void) incrementEventWithName:(NSString *)eventName
                           date:(NSDate *)date
                     completion:(TEALDictionaryCompletionBlock)completion;

- (void) reset;

@end