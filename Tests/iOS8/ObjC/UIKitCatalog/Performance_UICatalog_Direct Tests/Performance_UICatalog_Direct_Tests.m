//
//  Performance_UICatalog_Direct_Tests.m
//  Performance_UICatalog_Direct Tests
//
//  Created by George Webster on 1/13/15.
//  Copyright (c) 2015 f. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TEALMainMenuController.h"
#import "Tealium.h"
#import "TealiumConstants.h"
#import "TealiumActual.h"
#import "TealiumInternalConstants.h"

#import "TEALTestingHelpers.h"


@interface Performance_UICatalog_Direct_Tests : XCTestCase

@property (nonatomic, strong) TEALMainMenuController *mainViewController;

@property (nonatomic) size_t iterations;

@end

@implementation Performance_UICatalog_Direct_Tests

- (void)setUp {
    [super setUp];
    
    self.iterations = 100;
    
    __block BOOL isReady = NO;
    
    dispatch_async([TealiumInternalConstants sharedQueue],^{
        
        [TealiumActual initSharedInstance:@"tealiummobile" profile:@"demo" target:@"dev" options:0 globalCustomData:nil completionBlock:^(BOOL successful) {
            
            XCTAssert(successful, @"test library did not complete correctly");
            if (successful){
                XCTAssert([TealiumActual isActive], @"Library not actually finished enabling.");
            }
            isReady = YES;
        }];
    });
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    self.mainViewController = [TEALMainMenuController new];
}

- (void)tearDown {

    [super tearDown];
}


- (void)testClassTrackCallPerformance {

    uint64_t timeResult = dispatch_benchmark(self.iterations, ^{
        
        [Tealium trackCallType:TealiumViewCall
                    customData:@{@"some_key":@"some_value"}
                        object:self.mainViewController];
    });
    
    TEALTimerLog(timeResult, @"===> testClassTrackCallPerformance : ");
}

- (void)testInstanceTrackCallPerformance {

    uint64_t timeResult = dispatch_benchmark(self.iterations, ^{
        
        [TealiumActual trackCallType:TealiumViewCall
                          customData:@{@"some_key":@"some_value"}
                              object:self.mainViewController
                         autotracked:NO
                     completionBlock:nil];

    });
    
    TEALTimerLog(timeResult, @"===> testInstanceTrackCallPerformance : ");


}


@end
