//
//  TealiumTrackTests.m
//  TealiumiOS
//
//  Created by Jason Koo on 12/16/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TEALTestHelper.h"
#import "Tealium+PrivateHeader.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALDataSourceConstants.h"

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

//- (void) useLiveLibraryInstance {
//    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"setupLiveInstance"];
//    
//    self.library = [Tealium newInstanceForKey:TEAL_TEALIUMTRACK_TEST_INSTANCE_ID
//                                configuration:[self liveConfig]
//                                   completion:^(BOOL success, NSError * _Nullable error) {
//                                       
//                                       if (error){
//                                           NSLog(@"%s error:%@", __FUNCTION__, error);
//                                       }
//                                       
//                                       [expectation fulfill];
//                                       
//                                   }];
//    
//    [self waitForExpectationsWithTimeout:2.0 handler:nil];
//}

#pragma mark - TESTS

- (void) testTrackEventsNoTitleNoData {
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
        
        
        isReady = YES;
        
    }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    NSString *testTitle = @"testEventTitle";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_EventTitle: testTitle,
                                      TEAL_TEST_DATASOURCE_KEY: TEAL_TEST_DATASOURCE_STRING_VALUE
                                      };
    
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:testDataSources];
    
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                         
                         XCTAssert(!error, @"Error in track call detected");
                         
                         NSDictionary *dispatchData = returnDispatch.payload;
                         
                         XCTAssert([dispatchData[TEAL_TEST_DATASOURCE_KEY] isEqualToString:TEAL_TEST_DATASOURCE_STRING_VALUE], @"Incorrect test value in payload.");
                         
                     }];
    
#warning TODO
    // no title no data
    
    // title no data
    
    // title + data
    
    // no title + data
    
    XCTFail(@"Incomplete Test");
    
}

- (void) testTrackEventNoTitleWithData {
    
}

- (void) testTrackEventWithTitleAndData {
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};

    
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

- (void)testTrackEventWithTitleNoData {
    
}

- (void) testTrackViews {
    
#warning TODO
    // no title no data
    
    // title no data
    
    // title + data
    
    // no title + data
    
    XCTFail(@"Incomplete Test");
    
}


- (void) testFinalDispatchDataSourcesForEvents {
    
    // Create json file with all expected datasource keys
    
    // make a call to finalDispatchDataSources
    
    // check data sources from resulting dict against test json file keys
    
    XCTAssert("Complete test");
    
}

- (void) testFinalDispatchDataSourcesForViews {
    
    // Create json file with all expected datasource keys
    
    // make a call to finalDispatchDataSources
    
    // check data sources from resulting dict against test json file keys
    
    XCTAssert("Complete test");
    
}

@end
