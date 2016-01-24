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
@property int queueCount;

@end


NSString * const versionToTest = @"5.0.0";

@implementation TealiumTrackTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {

    self.library = nil;
    self.queueCount = 0;
    
    [super tearDown];
}

#pragma mark - HELPERS

- (void) useLiveLibraryInstanceWithConfig:(TEALConfiguration*)config {
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       XCTAssertTrue(!error, @"Error detected: %@", error);
                                       
                                       isReady = YES;
                                       
                                       
                                   }];
    
    [self.library setDelegate:self];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
}

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

- (NSDictionary *)dataSourcesForCurrentVersion{
    
    // ios_data_sources.json needs to be added to Test Target's Build Phases: Copy Bundle Resources
    
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

#pragma mark - TEALIUM DELEGATE

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
    self.queueCount ++;
    
    NSLog(@"%s queue count:%d", __FUNCTION__, self.queueCount);
    
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
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

#pragma mark - TRACK TESTS

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

#pragma mark - DISPATCH TESTS

- (void) testEventDispatchSendNow {
    
    [Tealium destroyInstanceForKey:self.description];
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper configFromTestHTMLFile:@"no_minutes_between_refresh"]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    
    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        if (error){
            NSLog(@"%s error:%@", __FUNCTION__, error);
        }
        
        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
        
    };
    
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:@{@"test_key":@"test_value"}];
    
    [self measureBlock:^{
        
        
        [self.library.dispatchManager addDispatch:dispatch
                                  completionBlock:completion];
        
    }];
}

- (void) testViewDispatchSendNow {
    
    [Tealium destroyInstanceForKey:self.description];
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper configFromTestHTMLFile:@"no_minutes_between_refresh"]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        if (error){
            NSLog(@"%s error:%@", __FUNCTION__, error);
        }
        
        XCTAssertEqual(status, TEALDispatchStatusSent, @"Dispatch: %@, should have been sent", dispatch);
        
    };
    
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeView
                                               withPayload:@{@"test_key":@"test_value"}];
    
    [self.library.dispatchManager addDispatch:dispatch
                              completionBlock:completion];
    
    
}

- (void) testEventDispatchWithNoDispatchServices {
    
    [self useLiveLibraryInstanceWithConfig:[TEALTestHelper configFromTestJSONFile:@"all_options_OFF"]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"no_dispatchers"];
    
    __block BOOL alreadyFulfilled = NO;
    
    [self.library trackDispatchOfType:TEALDispatchTypeEvent
                                title:@"test"
                          dataSources:@{}
                           completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                               
                               XCTAssert(status == TEALDispatchStatusQueued, @"Track call was not queued as expected - status:%lul error:%@", (unsigned long)status, error);
                               
                               if (!alreadyFulfilled){
                                   alreadyFulfilled = YES;
                                   [expectation fulfill];
                               }
                               
                           }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
   XCTAssertTrue(self.queueCount == 1, @"Queue count not expected - expected 1, got %i", self.queueCount);
}

#pragma mark - DISPATCH DATASOURCE TESTS

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
