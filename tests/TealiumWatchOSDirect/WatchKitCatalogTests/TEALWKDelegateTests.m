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
#import "TEALWKDelegate+PrivateHeader.h"
#import "TEALWKConstants.h"

@interface TEALWKDelegateTests : XCTestCase <TealiumDelegate>

@property BOOL queuedDispatchReceived;
@property BOOL dispatchSent;
@property Tealium *tealium;

@end

NSString * const TEALIUM_INSTANCE_ID = @"1";

@implementation TEALWKDelegateTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"no-tags"
                                                                environment:@"dev"];
    
    self.tealium = [Tealium newInstanceForKey:TEALIUM_INSTANCE_ID
                                configuration:config];
    
    [self.tealium setDelegate:self];
    
    self.queuedDispatchReceived = NO;
    self.dispatchSent = NO;
}

- (void)tearDown {

    self.queuedDispatchReceived = NO;
    self.dispatchSent = NO;
    
    [Tealium destroyInstanceForKey:TEALIUM_INSTANCE_ID];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void) testCallReceived {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TestCallExpectation"];
    
    [self sendTestCall];
    
    if (self.queuedDispatchReceived){
        [expectation fulfill];
    }
    
    [self waitForExpectationsWithTimeout:3.0
handler:^(NSError * _Nullable error) {
    
}];
    
    
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
    
    self.queuedDispatchReceived = YES;
    
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
    self.dispatchSent = YES;
    
}


@end
