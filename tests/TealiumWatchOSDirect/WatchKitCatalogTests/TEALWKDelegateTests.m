//
//  TEALWKDelegateTests.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/10/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TEALDataSourceConstants.h"
#import "Tealium+PrivateHeader.h"
#import "TEALWKConstants.h"
#import "TEALVersion.h"

@interface TEALWKDelegateTests : XCTestCase <TealiumDelegate>

@property BOOL didQueueDispatch;
@property BOOL didSendDispatch;
@property Tealium *tealium;

@end

NSString * const TEALIUM_INSTANCE_ID = @"1";

@implementation TEALWKDelegateTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [self tealiumInstanceWithConfig:[self configThatShouldQueue]];

    self.didQueueDispatch = NO;
    self.didSendDispatch = NO;
}

- (void)tearDown {

    self.didQueueDispatch = NO;
    self.didSendDispatch = NO;
    
    [Tealium destroyInstanceForKey:TEALIUM_INSTANCE_ID];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

- (TEALConfiguration*) configThatShouldQueue {
    
    return [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                profile:@"no-tags"
                                            environment:@"dev"];
}

- (Tealium*) tealiumInstanceWithConfig:(TEALConfiguration *)config {
    
    Tealium *tealium = [Tealium newInstanceForKey:TEALIUM_INSTANCE_ID
                                configuration:config];
    
    [tealium setDelegate:self];
    
    return tealium;
    
}

- (void) testCallReceived {
    
    [self sendTestCall];

    XCTAssertTrue(self.didQueueDispatch, @"WatchKit Extension emulated call did not result in a queued dispatch.");
    
}

- (void) sendTestCall {
    
    NSString *title = @"testCall";
    
    NSString *eventType = TEALWKCommandTrackValueEvent;
    
    double now = [[NSDate date] timeIntervalSince1970];
    
    NSString *nowString = [NSString stringWithFormat:@"%f", now];
    
    NSDictionary *customData = @{
                                 TEALDataSourceKey_TimestampUnix : nowString
                                 };
    
    NSDictionary *payload = @{
                              TEALWKCommandTrackKey:@{
                                      TEALWKCommandTrackArgumentTitleKey: title,
                                      TEALWKCommandTrackArgumentTypeKey: eventType,
                                      TEALWKCommandTrackArgumentInstanceIDKey: TEALIUM_INSTANCE_ID,
                                      TEALWKCommandTrackArgumentCustomDataKey: customData
                                      }
                              };
    
    [TEALWKDelegate processTrackCallFromPayload:payload];
    
}

#pragma mark - TEALIUM DELEGATES

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
    NSLog(@"%s ", __FUNCTION__);

    self.didQueueDispatch = YES;
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
    NSLog(@"%s ", __FUNCTION__);
    
    self.didSendDispatch = YES;
    
}


@end
