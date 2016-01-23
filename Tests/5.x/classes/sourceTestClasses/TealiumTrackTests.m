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

#pragma mark - DISPATCH TESTS

- (void) testTrackEventDispatchWithTitleAndData {
    
    [Tealium destroyInstanceForKey:self.description];
    
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
    
    __block BOOL alreadyFulfilled = NO;
    
    // Title + testData
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                         
                         NSLog(@"%s dispatch:%@", __FUNCTION__, returnDispatch);
                         
                         XCTAssert(!error, @"Error in track call detected:%@", error);
                         
                         NSDictionary *dispatchData = returnDispatch.payload;
                         
                         XCTAssert([dispatchData[TEAL_TEST_DATASOURCE_KEY] isEqualToString:TEAL_TEST_DATASOURCE_STRING_VALUE], @"Incorrect test value in payload.");
                         
                         XCTAssert([dispatchData[TEALDataSourceKey_EventTitle] isEqualToString:testTitle], "Incorrect title processed.");
                         
                         if (!alreadyFulfilled){
                             alreadyFulfilled = YES;
                             [expectation fulfill];
                         }
                     }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
}

- (void) testTrackEventDispatchNoTitleNoData {
    
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

    __block BOOL alreadyFulfilled = NO;
    
    // Title + testData
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                         
                         XCTAssert(!error, @"Error in track call detected:%@", error);
                         
                         NSDictionary *dispatchData = returnDispatch.payload;
                         
                         XCTAssert(!dispatchData[TEAL_TEST_DATASOURCE_KEY], @"Test value in payload when none should have been.");
                         
                         XCTAssert(!dispatchData[TEALDataSourceKey_EventTitle], "Title found when none should have been.");
                         
                         if (!alreadyFulfilled){
                             alreadyFulfilled = YES;
                             [expectation fulfill];
                         }
                     }];
 
    [self waitForExpectationsWithTimeout:1.0 handler:nil];

}

#pragma mark - TRACK + DISPATCH TESTS

- (void) testTrackEventNoTitleWithDataOverwritingAllStandardDataSources {
    
    [Tealium destroyInstanceForKey:self.description];
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    [self.library.dataSources purgePersistentDataSources];
    
    NSDictionary *payload = [TEALTestHelper overwriteDataSources];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch"];
    
    [self.library trackDispatchOfType:TEALDispatchTypeEvent
                                title:@"blah"
                          dataSources:payload
                           completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                               
                               XCTAssert(!error, @"Error in track call detected:%@", error);
                               
                               NSDictionary *dispatchData = dispatch.payload;
                               
                               NSArray *keys = [dispatchData allKeys];
                               
                               for (NSString *key in keys){
                                   
                                   NSString *value = dispatchData[key];
                                   
                                   XCTAssertTrue([value isEqualToString:payload[key]], @"Value for key %@ was not overwritten: overwrite payload: %@:  dispatchDataReceived:%@", key, payload, dispatchData);
                                   
                               }
                               
                               [expectation fulfill];
                               
                           }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
}

- (void) testTrackEventWithVolatileData {
    
    __block BOOL isReady = NO;
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"no_minutes_between_refresh"];
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    NSString *testKey = @"testKey";
    NSString *testValue = @"testValue";
    
    [self.library addVolatileDataSources:@{testKey:testValue}];
    
    NSString *testTitle = @"button_press";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_EventTitle: testTitle,
                                      @"intensity": @">9000"
                                      };
    
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch"];
    
    // Title + testData
    [self.library trackDispatchOfType:TEALDispatchTypeEvent
                                title:testTitle
                          dataSources:testDataSources
                           completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                               
                               NSLog(@"%s dispatch:%@", __FUNCTION__, dispatch);
                               
                               XCTAssert(!error, @"Error in track call detected:%@", error);
                               
                               NSDictionary *dispatchData = dispatch.payload;
                               
                               XCTAssertTrue([dispatchData[@"intensity"] isEqualToString:@">9000"], @"Incorrect test value in payload.");
                               
                               XCTAssertTrue([dispatchData[TEALDataSourceKey_EventTitle] isEqualToString:testTitle], "Incorrect title processed.");
                               
                               XCTAssertTrue([dispatchData[testKey] isEqualToString:testValue], @"volatile data sources {%@:%@} was not added to dispatch: %@", testKey, testValue, dispatchData);
                               
                               [expectation fulfill];
                               
                           }];
    
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
}

- (void) testTrackEventWithOverwriteVolatileData {
    
    __block BOOL isReady = NO;
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"no_minutes_between_refresh"];
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    NSDictionary * overwriteData = [TEALTestHelper overwriteDataSources];

    [self.library addVolatileDataSources:overwriteData];
    
    NSString *testTitle = @"button_press";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_EventTitle: testTitle,
                                      };
    
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch"];
    
    // Title + testData
    [self.library trackDispatchOfType:TEALDispatchTypeEvent
                                title:testTitle
                          dataSources:testDataSources
                           completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                               
           NSLog(@"%s dispatch:%@", __FUNCTION__, dispatch);
           
           XCTAssert(!error, @"Error in track call detected:%@", error);
           
           NSDictionary *dispatchData = dispatch.payload;
           
           NSArray *keys = [dispatchData allKeys];
           
           for (NSString *key in keys){
               
               if ([key isEqualToString:TEALDataSourceKey_EventTitle]){
                   
                  XCTAssertTrue([dispatchData[key] isEqualToString:testTitle], "Incorrect title processed.");
                   
               } else {
                   
               NSString *value = dispatchData[key];
               
               XCTAssertTrue([value isEqualToString:overwriteData[key]], @"Value for key %@ was not overwritten: overwrite payload: %@:  dispatchDataReceived:%@", key, overwriteData, dispatchData);
               }
               
           }
           
           [expectation fulfill];
           
       }];
    
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
}

- (void) testTrackEventWithPersistentData {
    
    __block BOOL isReady = NO;
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"no_minutes_between_refresh"];
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    NSString *testKey = @"testKey";
    NSString *testValue = @"testValue";
    
    [self.library addPersistentDataSources:@{testKey:testValue}];
    
    NSString *testTitle = @"button_press";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_EventTitle: testTitle,
                                      @"intensity": @">9000"
                                      };
    
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch"];
    
    __block BOOL alreadyFulfilled = NO;
    
    [self.library trackDispatchOfType:TEALDispatchTypeEvent
                                title:testTitle
                          dataSources:testDataSources
                           completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                               
                               NSLog(@"%s dispatch:%@", __FUNCTION__, dispatch);
                               
                               XCTAssert(!error, @"Error in track call detected:%@", error);
                               
                               NSDictionary *dispatchData = dispatch.payload;
                               
                               XCTAssertTrue([dispatchData[@"intensity"] isEqualToString:@">9000"], @"Incorrect test value in payload.");
                               
                               XCTAssertTrue([dispatchData[TEALDataSourceKey_EventTitle] isEqualToString:testTitle], "Incorrect title processed.");
                               
                               XCTAssertTrue([dispatchData[testKey] isEqualToString:testValue], @"persistent data sources {%@:%@} was not added to dispatch: %@", testKey, testValue, dispatchData);
                               
                               if (!alreadyFulfilled){
                                   alreadyFulfilled = YES;
                                   [expectation fulfill];
                               }
                               
                           }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
}

//- (NSDictionary *) overrwriteDataSources {
//    
//    NSString *value = @"overwriteValue";
//    
//    NSDictionary *testDataSources = @{
//                                      TEALDataSourceKey_ApplicationName: value,
//                                      TEALDataSourceKey_ApplicationRDNS: value,
//                                      TEALDataSourceKey_ApplicationVersion: value,
//                                      TEALDataSourceKey_CallType: value,
//                                      TEALDataSourceKey_Carrier: value,
//                                      TEALDataSourceKey_CarrierISO: value,
//                                      TEALDataSourceKey_CarrierMCC: value,
//                                      TEALDataSourceKey_CarrierMNC: value,
//                                      TEALDataSourceKey_ConnectionType: value,
//                                      TEALDataSourceKey_Device: value,
//                                      TEALDataSourceKey_DeviceArchitecture: value,
//                                      TEALDataSourceKey_DeviceBatteryLevel: value,
//                                      TEALDataSourceKey_DeviceCPUType: value,
//                                      TEALDataSourceKey_DeviceIsCharging: value,
//                                      TEALDataSourceKey_DeviceLanguage: value,
//                                      TEALDataSourceKey_DeviceOrientation: value,
//                                      TEALDataSourceKey_DeviceOSVersion: value,
//                                      TEALDataSourceKey_DeviceResolution: value,
//                                      TEALDataSourceKey_LibraryVersion: value,
//                                      TEALDataSourceKey_EventTitle: value,
//                                      TEALDataSourceKey_Orientation: value,
//                                      TEALDataSourceKey_Origin: value,
//                                      TEALDataSourceKey_SystemVersion: value,
//                                      TEALDataSourceKey_EventName: value,
//                                      TEALDataSourceKey_Pagetype: value,
//                                      TEALDataSourceKey_Platform: value,
//                                      TEALDataSourceKey_ViewTitle: value,
//                                      TEALDataSourceKey_Timestamp: value,
//                                      TEALDataSourceKey_TimestampLocal: value,
//                                      TEALDataSourceKey_TimestampOffset: value,
//                                      TEALDataSourceKey_TimestampUnix: value,
//                                      TEALDataSourceKey_UUID: value,
//                                      TEALDataSourceKey_VisitorID: value,
//                                      TEALDataSourceKey_WasQueued: value
//                                      };
//    
//    return testDataSources;
//    
//}

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

- (void) testFinalDispatchDataSourceKeysForEvents {
    
    [self startLiveConfigLibrary];
    
    NSDictionary *requiredEventDataSources = [self dataSourcesForCurrentVersion][@"event"];
    
    // make a call to finalDispatchDataSources
    NSDictionary *dispatchData = [self.library finalDispatchDataSourcesForDispatchType:TEALDispatchTypeEvent title:@"test" dataSources:nil];
    
    NSArray *requiredKeys = [requiredEventDataSources allKeys];
    
    // NOTE: Carrier info ONLY available if CoreTelephony.framework was added to project
    
    for (NSString *key in requiredKeys) {
        
        NSString *dispatchValue = dispatchData[key];
        
        XCTAssert(dispatchValue, "Key-value missing from dispatch data: %@", key);
        
    }
    
}

- (void) testFinalDispatchDataSourceKeysForViews {
    
    [self startLiveConfigLibrary];
    
    NSDictionary *requiredEventDataSources = [self dataSourcesForCurrentVersion][@"view"];
    
    // make a call to finalDispatchDataSources
    NSDictionary *dispatchData = [self.library finalDispatchDataSourcesForDispatchType:TEALDispatchTypeView title:@"test" dataSources:nil];
    
    NSArray *requiredKeys = [requiredEventDataSources allKeys];
    
    // NOTE: Carrier info ONLY available if CoreTelephony.framework was added to project

    for (NSString *key in requiredKeys) {
        
        NSString *dispatchValue = dispatchData[key];
        
        XCTAssert(dispatchValue, "Key-value missing from dispatch data: %@", key);
        
    }
    
}

@end
