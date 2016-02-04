//
//  TealiumTrackTests.m
//  TealiumiOS
//
//  Created by Jason Koo on 12/16/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Foundation/Foundation.h>
#import "NSDictionary+Tealium.h"
#import "TEALTestHelper.h"
#import "Tealium+PrivateHeader.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALDataSourceConstants.h"

@interface TealiumTrackTests : XCTestCase <TealiumDelegate>

@property Tealium *library;
@property int queueCount;
@property int sentCount;
@property BOOL callBackReceived;
@property BOOL didFetch;

@end


NSString * const versionToTest = @"5.0.0";

@implementation TealiumTrackTests

- (void)setUp {
    [super setUp];
    self.callBackReceived = NO;
    self.queueCount = 0;
    self.sentCount = 0;
    self.didFetch = NO;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {

    self.library = nil;

    [super tearDown];
}

#pragma mark - HELPERS

- (void) useLibraryInstanceWithConfig:(TEALConfiguration*)config {
    
    __block BOOL isReady = NO;
    __block BOOL initSuccess = NO;
    __block NSError *initError = nil;
    
    [Tealium destroyInstanceForKey:@"trackTests"];
    
    self.library = [Tealium newInstanceForKey:@"trackTests"
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       initError = error;
                                       initSuccess = success;
                                       isReady = YES;
                                       
                                   }];
    
    [self.library setDelegate:self];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    XCTAssertTrue(initSuccess, @"Library did not init correctly");
    
    XCTAssertTrue(!initError, @"Error detected: %@", initError);

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
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ios_data_sources_before_queueing" ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if (!data) {
        XCTFail("Could not retrieve ios_data_sources.json file.");
        return nil;
    }
    
    NSError *error = nil;
    
    id content = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (![content isKindOfClass:[NSDictionary class]]){
        XCTFail("ios_data_sources_before_queueing.json not of correct dictionary format, error: %@", error);
        return nil;
    }
    
    NSDictionary *requiredDataSources = (NSDictionary*)content;
    
    return requiredDataSources[versionToTest];
    
}

#pragma mark - TEALIUM DELEGATE

- (void) tealiumInstanceDidUpdatePublishSettings:(Tealium *)tealium {
    
    self.didFetch = YES;
    
}

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
    self.queueCount++;
    self.callBackReceived = YES;
    NSLog(@"%s queue count:%d", __FUNCTION__, self.queueCount);
    
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
    self.sentCount++;
    self.callBackReceived = YES;
}

#pragma mark - DISPATCH TESTS

- (void) testQueueEventDispatchWithTitleAndData {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"all_options_OFF"];
    
    [self useLibraryInstanceWithConfig:config];
    
    NSString *testTitle = @"testEventTitle";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_EventTitle: testTitle,
                                      TEAL_TEST_DATASOURCE_KEY: TEAL_TEST_DATASOURCE_STRING_VALUE
                                      };
    
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent
                                               withPayload:testDataSources];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatchWithTitleAndData"];
    
    __block TEALDispatchStatus dispatchStatus;
    __block TEALDispatch *dispatchReturned = nil;
    __block NSError *dispatchError = nil;
    
    // Title + testData
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                         
                         dispatchError = error;
                         dispatchStatus = status;
                         dispatchReturned = returnDispatch;
                         
                         [expectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:0.5 handler:nil];
    
    XCTAssertTrue(dispatchReturned, @"No dispatch returned from track call.");
    
    XCTAssertTrue(!dispatchError, @"Error in track call detected:%@", dispatchError);
    
    NSDictionary *dispatchData = dispatchReturned.payload;
    
    XCTAssertTrue([dispatchData[TEAL_TEST_DATASOURCE_KEY] isEqualToString:TEAL_TEST_DATASOURCE_STRING_VALUE], @"Incorrect test value in payload.");
    
    XCTAssertTrue([dispatchData[TEALDataSourceKey_EventTitle] isEqualToString:testTitle], "Incorrect title processed.");
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
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatchNoTitleNoData"];

    __block BOOL alreadyFulfilled = NO;
    
    // Title + testData
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                         
                         
                         if (status != TEALDispatchStatusSent){
                             return;
                         }
                         
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
    
    TEALConfiguration *config = [TEALTestHelper liveConfig];

    [self useLibraryInstanceWithConfig:config];
    
    [self.library.dataSources purgePersistentDataSources];
    
    NSDictionary *payload = [TEALTestHelper overwriteDataSources];
    
    __block BOOL isReady = NO;
    __block NSError *dispatchError = nil;
    __block NSString *incorrectKey = nil;
    __block NSString *incorrectValue = nil;
//    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatchNoTitleOverwriteDataSources"];
    
    [self.library trackDispatchOfType:TEALDispatchTypeEvent
                                title:@"blah"
                          dataSources:payload
                           completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                               
                               
                               if (status != TEALDispatchStatusSent){
                                   return;
                               }
                               
                               dispatchError = error;
                               
                               NSDictionary *dispatchData = dispatch.payload;
                               
                               NSArray *keys = [dispatchData allKeys];
                               
                               for (NSString *key in keys){
                                   
                                   NSString *value = dispatchData[key];
                                   
                                   if (![value isEqualToString:payload[key]]){
                                       incorrectKey = key;
                                       incorrectValue = value;
                                   }
                                   
                               }
                               
                               isReady = YES;
//                               [expectation fulfill];
                               
                           }];
    
    [TEALTestHelper waitFor:&isReady timeout:1.0];
    
    XCTAssertTrue(isReady, @"Dispatch never completed.");
//    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssert(!dispatchError, @"Error in track call detected:%@", dispatchError);

    XCTAssertTrue(!incorrectKey, @"Value for key %@ was not overwritten - value: %@ expected value: %@", incorrectKey, incorrectValue, payload[incorrectKey]);

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
    
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatchEventVolatileData"];
    
    // Title + testData
    [self.library trackDispatchOfType:TEALDispatchTypeEvent
                                title:testTitle
                          dataSources:testDataSources
                           completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                               
                               
                               if (status != TEALDispatchStatusSent){
                                   return;
                               }
                               
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
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"no_minutes_between_refresh"];
    
    [self useLibraryInstanceWithConfig:config];
    
    NSDictionary * overwriteData = [TEALTestHelper overwriteDataSources];

    [self.library addVolatileDataSources:overwriteData];
    
    __block int numberofDispatches = 0;
    __block BOOL alreadyFulfilled = NO;
    __block NSError *dispatchError = nil;
    __block NSString *incorrectKey = nil;
    __block NSString *incorrectValue = nil;
    
    __block BOOL isReady = NO;
    
    // Title + testData
    [self.library trackDispatchOfType:TEALDispatchTypeEvent
                                title:@"blah"
                          dataSources:nil
                           completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                             
           if (status != TEALDispatchStatusSent){
               return;
           }
                              
           dispatchError = error;
           
           NSDictionary *dispatchData = dispatch.payload;
           
           NSArray *keys = [dispatchData allKeys];
           
           for (NSString *key in keys){
                   
               NSString *value = dispatchData[key];
               
               if (![overwriteData[key] isEqualToString:value]){
                   incorrectKey = key;
                   incorrectValue = value;
               }
               
           }
           
           numberofDispatches++;
                               
           if (numberofDispatches==1){
               if (!alreadyFulfilled){
                   alreadyFulfilled = YES;
                   
                   
                   isReady = YES;
//                   [expectation fulfill];
               }
           }
           
       }];
    
    
//    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    [TEALTestHelper waitFor:&isReady timeout:1.0];
    
    XCTAssertTrue(isReady, @"Dispatch never finished processing.");

    XCTAssert(!dispatchError, @"Error in track call detected:%@", dispatchError);

    XCTAssertTrue(!incorrectKey, @"Value for key %@ was not overwritten, value: %@ - correct value:%@", incorrectKey , incorrectValue, overwriteData[incorrectKey]);

    XCTAssertTrue(numberofDispatches == 1, @"Too many dispatches detected: %i", numberofDispatches);
}

- (void) testTrackEventWithPersistentData {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"no_minutes_between_refresh"];

    [self useLibraryInstanceWithConfig:config];
    
    NSString *testKey = @"testKey";
    NSString *testValue = @"testValue";
    
    [self.library addPersistentDataSources:@{testKey:testValue}];
    
    NSString *testTitle = @"button_press";
    
    NSDictionary *testDataSources = @{
                                      TEALDataSourceKey_EventTitle: testTitle,
                                      @"intensity": @">9000"
                                      };
    
    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"dispatch"];
    
    __block BOOL alreadyFulfilled = NO;
    
    [self.library trackDispatchOfType:TEALDispatchTypeEvent
                                title:testTitle
                          dataSources:testDataSources
                           completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                               
                               
                               if (status != TEALDispatchStatusSent){
                                   return;
                               }
                               
                               NSLog(@"%s dispatch:%@", __FUNCTION__, dispatch);
                               
                               XCTAssert(!error, @"Error in track call detected:%@", error);
                               
                               NSDictionary *dispatchData = dispatch.payload;
                               
                               XCTAssertTrue([dispatchData[@"intensity"] isEqualToString:@">9000"], @"Incorrect test value in payload.");
                               
                               XCTAssertTrue([dispatchData[TEALDataSourceKey_EventTitle] isEqualToString:testTitle], "Incorrect title processed.");
                               
                               XCTAssertTrue([dispatchData[testKey] isEqualToString:testValue], @"persistent data sources {%@:%@} was not added to dispatch: %@", testKey, testValue, dispatchData);
                               
                               if (!alreadyFulfilled){
                                   alreadyFulfilled = YES;
//                                   [expectation fulfill];
                               }
                               
                           }];
    
    [TEALTestHelper waitFor:&alreadyFulfilled timeout:1.0];
//    [self waitForExpectationsWithTimeout:1.5 handler:nil];
    
}


#pragma mark - DISPATCH DATASOURCE TESTS

- (NSDictionary *) allDataSourcesForDispatchForType:(TEALDispatchType)type
                                              title:(NSString *)title
                                  clientDataSources:(NSDictionary *)clientDataSources{
    
    // Emulates trackDispatchOfType:title:dataSources:completion with queue
    // logic removed - not optimal
    
    NSDictionary *captureData = [self.library captureTimeDataSourcesForType:type
                                                              title:title];
    NSDictionary *clientData = [clientDataSources copy];
    
    NSDictionary *backgroundData = [self.library.dataSources backgroundSafeDataSources];
    NSDictionary *payload = [NSDictionary teal_compositeDictionaries:@[
                                                                       captureData,
                                                                       backgroundData,
                                                                       clientData? clientData : @{}
                                                                       ]];
    
    return payload;
}

- (void) testExpectedDispatchDataSourceKeysForEventsNoClientData {
    
    [self useLibraryInstanceWithConfig:[TEALTestHelper liveConfig]];
    
    NSDictionary *requiredEventDataSources = [self dataSourcesForCurrentVersion][@"event"];
    
    NSDictionary *dispatchPayload = [self allDataSourcesForDispatchForType:TEALDispatchTypeEvent
                                                                     title:@"title" clientDataSources:nil];
    
    NSArray *requiredKeys = [requiredEventDataSources allKeys];
    
    // NOTE: Carrier info ONLY available if CoreTelephony.framework was added to project
    
    for (NSString *key in requiredKeys) {
        
        NSString *dispatchValue = dispatchPayload[key];
        
        XCTAssert(dispatchValue, "Key-value missing from dispatch data: %@", key);
        
    }
    
}

- (void) testExpectedDispatchDataSourceKeysForViewsNoClientData {
    
    [self useLibraryInstanceWithConfig:[TEALTestHelper liveConfig]];

//    [self startLiveConfigLibrary];
    
    NSDictionary *requiredEventDataSources = [self dataSourcesForCurrentVersion][@"view"];
    
    NSDictionary *dispatchPayload = [self allDataSourcesForDispatchForType:TEALDispatchTypeView
                                                                     title:@"title" clientDataSources:nil];
    
    NSArray *requiredKeys = [requiredEventDataSources allKeys];
    
    // NOTE: Carrier info ONLY available if CoreTelephony.framework was added to project

    for (NSString *key in requiredKeys) {
        
        NSString *dispatchValue = dispatchPayload[key];
        
        XCTAssert(dispatchValue, "Key-value missing from dispatch data: %@", key);
        
    }
    
}

@end
