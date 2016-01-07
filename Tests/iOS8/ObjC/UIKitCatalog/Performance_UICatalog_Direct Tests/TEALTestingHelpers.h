//
//  TEALTestingHelpers.h
//  Performance_UICatalog
//
//  Created by George Webster on 1/14/15.
//  Copyright (c) 2015 f. All rights reserved.
//

#ifndef Performance_UICatalog_TEALTestingHelpers_h
#define Performance_UICatalog_TEALTestingHelpers_h

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

static NSTimeInterval TEALSecondsFromNanoSectonds( uint64_t nano) {
    return nano * ( 1 / 1e9 );
}

static NSTimeInterval TEALMillisecondsFromNanoSectonds( uint64_t nano) {
    return nano * ( 1 / 1e6 );
}

static void TEALTimerLog( uint64_t nanoseconds, NSString *text) {
    
    float seconds = TEALSecondsFromNanoSectonds(nanoseconds);
    float milliseconds = TEALMillisecondsFromNanoSectonds(nanoseconds);
    
    NSLog(@"%@ Avg. Runtime: %f seconds, %f millisecond, %llu nanoseconds.", text, seconds, milliseconds, nanoseconds);
}

#endif
