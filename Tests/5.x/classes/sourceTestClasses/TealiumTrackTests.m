//
//  TealiumTrackTests.m
//  TealiumiOS
//
//  Created by Jason Koo on 12/16/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Foundation/Foundation.h>
#import "TEALTestHelper.h"
#import "Tealium+PrivateHeader.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALDataSourceConstants.h"

@interface TealiumTrackTests : XCTestCase <TealiumDelegate>

@property Tealium *library;
@property int count;

@end


NSString * const versionToTest = @"5.0.0";

@implementation TealiumTrackTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {

    self.library = nil;
    self.count = 0;
    
    [super tearDown];
}

#pragma mark - HELPERS

- (void) startLiveConfigLibrary {
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};

}

- (void) startLiveConfigWithBatchLibrary {
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper configFromTestJSONFile:@"batch_5"]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
}

#pragma mark - TEALIUM DELEGATE

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
    self.count ++;
    
}

#pragma mark - TESTS

- (void) testTrackEventWithTitleAndData {
    
    __block BOOL isReady = NO;
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"no_minutes_between_refresh"];
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
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
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch"];
    
    // Title + testData
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                         
                         NSLog(@"%s dispatch:%@", __FUNCTION__, returnDispatch);
                         
                         XCTAssert(!error, @"Error in track call detected:%@", error);
                         
                         NSDictionary *dispatchData = returnDispatch.payload;
                         
                         XCTAssert([dispatchData[TEAL_TEST_DATASOURCE_KEY] isEqualToString:TEAL_TEST_DATASOURCE_STRING_VALUE], @"Incorrect test value in payload.");
                         
                         XCTAssert([dispatchData[TEALDataSourceKey_EventTitle] isEqualToString:testTitle], "Incorrect title processed.");
                         
                         [expectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
}

- (void) testTrackEventNoTitleNoData {
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch"];

    // Title + testData
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                         
                         XCTAssert(!error, @"Error in track call detected:%@", error);
                         
                         NSDictionary *dispatchData = returnDispatch.payload;
                         
                         XCTAssert(!dispatchData[TEAL_TEST_DATASOURCE_KEY], @"Test value in payload when none should have been.");
                         
                         XCTAssert(!dispatchData[TEALDataSourceKey_EventTitle], "Title found when none should have been.");
                         
                         [expectation fulfill];
                     }];
 
    [self waitForExpectationsWithTimeout:1.0 handler:nil];

}

//- (void) testTrackBatchedEvent {
// 
//    [self startLiveConfigWithBatchLibrary];
//    
//    self.library.delegate = self;
//
//    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent withPayload:nil];
//    
//    XCTestExpectation *batchExpectation = [self expectationWithDescription:@"batch"];
//    
//    __block BOOL fulfilledAlready = NO;
//    
//    __block typeof(self) __weak weakSelf = self;
//
//    for (int i = 0; i < 5; i++) {
//        
//        [self.library trackDispatch:dispatch
//                         completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
//                             
//                             XCTAssert(!error, @"Error in track call detected:%@", error);
//                             
//                             XCTAssertTrue(status == 2, @"Dispatch was not queued as expected:%@", returnDispatch);
//                             
//                             if (weakSelf.count >= 5 &&
//                                 fulfilledAlready == NO){
//                                 fulfilledAlready = YES;
//                                 
//                                 [batchExpectation fulfill];
//                             }
//                         }];
//        
//    }
//    
//    [self waitForExpectationsWithTimeout:3.0 handler:nil];
//    
//    
//    XCTAssertTrue(self.count == 5, @"5 events did not trigger");
//    
//    fulfilledAlready = NO;
//    
//    XCTestExpectation *lastCallExpectation = [self expectationWithDescription:@"batch"];
//
//    [self.library trackDispatch:dispatch
//                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
//                         
//                         XCTAssert(!error, @"Error in track call detected:%@", error);
//                         
//                         XCTAssertTrue(status == 1, @"Dispatch was not sent as expected:%@", returnDispatch);
//                         
//                         if (!fulfilledAlready){
//                             
//                             fulfilledAlready = YES;
//                             [lastCallExpectation fulfill];
//                             
//                         }
//                     }];
//    
//    [self waitForExpectationsWithTimeout:1.0 handler:nil];
//    
//}


- (void) testTrackViews {
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};

    
    NSString *testTitle = @"testViewTitle";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_ViewTitle: testTitle,
                                      TEAL_TEST_DATASOURCE_KEY: TEAL_TEST_DATASOURCE_STRING_VALUE
                                      };
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:testDataSources];
    
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                         
                         
                         XCTAssert(!error, @"Error in track call detected");
                         
                         NSDictionary *dispatchData = returnDispatch.payload;
                         
                         XCTAssert([dispatchData[TEAL_TEST_DATASOURCE_KEY] isEqualToString:TEAL_TEST_DATASOURCE_STRING_VALUE], @"Incorrect test value in payload.");
                         
                         NSString *dispatchTitle = dispatchData[TEALDataSourceKey_ViewTitle];
                         
                         XCTAssert([dispatchTitle isEqualToString:testTitle], "Incorrect title processed - dispatch title:%@ test title:%@", dispatchTitle, testTitle);
                         
                     }];
    
}

- (NSDictionary *)dataSourcesForCurrentVersion{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ios_data_sources" ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if (!data) {
        XCTFail("Could not retrieve ios_data_sources.json file.");
        return nil;
    }
    
    NSError *error = nil;
    
    id content = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (![content isKindOfClass:[NSDictionary class]]){
        XCTFail("ios_data_sources.json not of correct dictionary format, error: %@", error);
        return nil;
    }
    
    NSDictionary *requiredDataSources = (NSDictionary*)content;
    
    return requiredDataSources[versionToTest];

}

- (void) testFinalDispatchDataSourcesForEvents {
    
    [self startLiveConfigLibrary];
    
    NSDictionary *requiredEventDataSources = [self dataSourcesForCurrentVersion][@"event"];
    
    // make a call to finalDispatchDataSources
    NSDictionary *dispatchData = [self.library finalDispatchDataSourcesForDispatchType:TEALDispatchTypeEvent title:@"test" dataSources:nil];
    
    NSArray *requiredKeys = [requiredEventDataSources allKeys];
    
    for (NSString *key in requiredKeys) {
        
        NSString *dispatchValue = dispatchData[key];
        
        XCTAssert(dispatchValue, "Key-value missing from dispatch data: %@", key);
        
    }
    
}

- (void) testFinalDispatchDataSourcesForViews {
    
    [self startLiveConfigLibrary];
    
    NSDictionary *requiredEventDataSources = [self dataSourcesForCurrentVersion][@"view"];
    
    // make a call to finalDispatchDataSources
    NSDictionary *dispatchData = [self.library finalDispatchDataSourcesForDispatchType:TEALDispatchTypeView title:@"test" dataSources:nil];
    
    NSArray *requiredKeys = [requiredEventDataSources allKeys];
    
    for (NSString *key in requiredKeys) {
        
        NSString *dispatchValue = dispatchData[key];
        
        XCTAssert(dispatchValue, "Key-value missing from dispatch data: %@", key);
        
    }
    
}

@end
