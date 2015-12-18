//
//  TealiumTrackTests.m
//  TealiumiOS
//
//  Created by Jason Koo on 12/16/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tealium+PrivateHeader.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALDataSourceConstants.h"

NSString * const TEAL_TEALIUMTRACK_TEST_INSTANCE_ID = @"testTealiumTrack";

@interface TealiumTrackTests : XCTestCase

@property Tealium *library;

@end

@implementation TealiumTrackTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {

    self.library = nil;
    
    [super tearDown];
}

#pragma mark - HELPERS

- (TEALConfiguration *) liveConfig {
    
    return [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                               profile:@"demo"
                                           environment:@"dev"];
}

- (TEALConfiguration *) nonExistentConfig {
    
    return [TEALConfiguration configurationWithAccount:@"what"
                                               profile:@"who"
                                           environment:@"wow"];
    
}

- (void) useLiveLibraryInstance {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"setupLiveInstance"];
    
    self.library = [Tealium newInstanceForKey:TEAL_TEALIUMTRACK_TEST_INSTANCE_ID
                                configuration:[self liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       if (error){
                                           NSLog(@"%s error:%@", __FUNCTION__, error);
                                       }
                                       
                                       [expectation fulfill];
                                       
                                   }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

#pragma mark - TESTS

- (void) testTrackEventsNoTitleNoData {
    
    [self useLiveLibraryInstance];
    
    NSString *testTitle = @"testEventTitle";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_EventTitle: testTitle,
                                      @"testKey":@"testValue"
                                      };
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:testDataSources];
    
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                         
                     }];
    
#warning TODO
    // no title no data
    
    // title no data
    
    // title + data
    
    // no title + data
    
    XCTFail(@"Incomplete Test");
    
}

- (void) testTrackEventWithTitleAndData {
    
    [self useLiveLibraryInstance];
    
    NSString *testTitle = @"testEventTitle";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_EventTitle: testTitle,
                                      @"testKey":@"testValue"
                                      };
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:testDataSources];
    
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                         
                     }];
    
}

- (void) testTrackViews {
    
#warning TODO
    // no title no data
    
    // title no data
    
    // title + data
    
    // no title + data
    
    XCTFail(@"Incomplete Test");
    
}


@end
