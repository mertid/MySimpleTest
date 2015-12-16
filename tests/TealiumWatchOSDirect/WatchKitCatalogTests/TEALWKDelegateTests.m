//
//  TEALWKDelegateTests.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/10/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//
//  Test the Tealium+WatchKit Category - formerlly and independent class

#import <XCTest/XCTest.h>
#import "Tealium+WatchKit.h"
#import "Tealium+PrivateHeader.h"
#import "TEALDataSourceConstants.h"
#import "TEALWKConstants.h"
#import "TEALVersion.h"

@interface TEALWKDelegateTests : XCTestCase <TealiumDelegate>

@property BOOL didQueueDispatch;
@property BOOL didSendDispatch;
@property Tealium *tealium;

@end

NSString * const TEALIUM_INSTANCE_ID = @"1";

@implementation TEALWKDelegateTests

#pragma mark - SETUP

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.tealium = [self tealiumInstanceWithConfig:[self configThatShouldQueue]];

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

- (TEALConfiguration*) configThatShouldQueue {
    
    return [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                profile:@"no-tags"
                                            environment:@"dev"];
}

- (Tealium*) tealiumInstanceWithConfig:(TEALConfiguration *)config {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"tealiumInit"];
    
    Tealium *tealium = [Tealium newInstanceForKey:TEALIUM_INSTANCE_ID
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                    
                                       [expectation fulfill];
                                           
                                   }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    
    [tealium setDelegate:self];
    
    return tealium;
    
}

#pragma mark - TESTS

- (void) testCallReceived {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCall"];
    
    NSString *title = @"testCall";
    
    NSString *eventType = TEALWKCommandTrackValueEvent;
    
    double now = [[NSDate date] timeIntervalSince1970];
    
    NSString *nowString = [NSString stringWithFormat:@"%f", now];
    
    NSDictionary *customData = @{
                                 TEALDataSourceKey_TimestampUnix : nowString
                                 };
    
    __block NSDictionary *payload = @{
                              TEALWKCommandTrackKey:@{
                                      TEALWKCommandTrackArgumentTitleKey: title,
                                      TEALWKCommandTrackArgumentTypeKey: eventType,
                                      TEALWKCommandTrackArgumentInstanceIDKey: TEALIUM_INSTANCE_ID,
                                      TEALWKCommandTrackArgumentCustomDataKey: customData
                                      }
                              };
    
    __block NSDictionary *incorrectTargetPayload = @{
                                                     @"wakkaWakka":@{
                                                             TEALWKCommandTrackArgumentTitleKey: title,
                                                             TEALWKCommandTrackArgumentTypeKey: eventType,
                                                             TEALWKCommandTrackArgumentInstanceIDKey: TEALIUM_INSTANCE_ID,
                                                             TEALWKCommandTrackArgumentCustomDataKey: customData
                                                             }
                                                     };
    
    __block NSDictionary *incorrectPayloadContent = @{
                                                     TEALWKCommandTrackKey:@{
                                                             TEALWKCommandTrackArgumentTitleKey: @"someOtherTitle",
                                                             TEALWKCommandTrackArgumentTypeKey: eventType,
                                                             TEALWKCommandTrackArgumentInstanceIDKey: TEALIUM_INSTANCE_ID,
                                                             TEALWKCommandTrackArgumentCustomDataKey: customData
                                                             }
                                                     };
    
    [self.tealium session:[WCSession defaultSession] didReceiveMessage:payload replyHandler:^(NSDictionary<NSString *,id> *replyMessage) {
        
        [expectation fulfill];
        
        NSLog(@"%s replyMessage:%@", __FUNCTION__, replyMessage);
        
        NSDictionary *responseMessagePayload = replyMessage[@"message"];
        
        XCTAssert([payload isEqualToDictionary:responseMessagePayload], @"Message payload returned did not match payload sent.");
        XCTAssert(![incorrectTargetPayload isEqualToDictionary:responseMessagePayload], @"Message payload returned a payload with incorrect tealium message key.");
        XCTAssert(![incorrectPayloadContent isEqualToDictionary:responseMessagePayload], @"Message payload returned did not match payload sent.");

        
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    
    XCTAssertTrue(self.didQueueDispatch, @"WatchKit Extension emulated call did not result in a queued dispatch.");
    
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
