//
//  TealiumTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TEALTestHelper.h"
#import "TealiumDelegateTestObject.h"
#import "Tealium+PrivateHeader.h"
#import "TEALSettings+PrivateHeader.h"

@interface TealiumPublicAPITests : XCTestCase <TealiumDelegate>

@property (nonatomic) BOOL shouldQueue;
@property (nonatomic) BOOL shouldDrop;
@property (nonatomic) BOOL didUpdate;
@property (nonatomic, strong) Tealium *library;

@end

@implementation TealiumPublicAPITests

- (void)setUp {
    [super setUp];
    
    self.shouldDrop = NO;
    self.shouldQueue = NO;
    self.didUpdate = NO;
    self.library = nil;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - HELPERS

- (void) useLibraryInstanceWithConfig:(TEALConfiguration *)config {
    
    NSString *testID = @"publicAPITests";
    
    [Tealium destroyInstanceForKey:testID];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"setupLiveInstance"];
    
    self.library = [Tealium newInstanceForKey:testID
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       if (error){
                                           NSLog(@"%s error:%@", __FUNCTION__, error);
                                       }
                                       
                                       [expectation fulfill];
                                       
                                   }];
    
    self.library.delegate = self;
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

- (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!*flag);
    return *flag;
}

- (NSDictionary *) stringDataSources {
    
    NSString *testKey = TEAL_TEST_DATASOURCE_KEY;
    NSString *testValue = TEAL_TEST_DATASOURCE_STRING_VALUE;
    
    NSDictionary *testDataSources = @{
                                      testKey : testValue
                                      };
    return testDataSources;
    
}


- (NSDictionary *) mixedDataSources {
    
    NSString *testKey = TEAL_TEST_DATASOURCE_KEY;
    NSString *testValue = TEAL_TEST_DATASOURCE_STRING_VALUE;
    
    NSString * testNumberKey = @"testNumberKey";
    NSNumber * testNumber = @1234;
    
    NSDictionary *testDataSources = @{
                                      testKey : testValue,
                                      testNumberKey : testNumber
                                      };
    return testDataSources;
}


- (NSDictionary *) dataSourcesWithTimestampUnixOverride {
    
    
    NSString *testKey = TEAL_TEST_DATASOURCE_KEY;
    NSString *testValue = TEAL_TEST_DATASOURCE_STRING_VALUE;
    
    NSDictionary *testDataSources = @{
                                      testKey : testValue,
                                      TEALDataSourceKey_TimestampUnix : @0
                                      
                                      };
    return testDataSources;
    
    
}

#pragma mark - newInstanceForKey:configuration: TESTS

- (void) testCreateInvalidInstance {
    
    [Tealium destroyInstanceForKey:@"failTest"];

    XCTestExpectation *e = [self expectationWithDescription:@"invalidInstance"];
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"does-not-exist"
                                                                environment:@"dev"];
    
    self.library = [Tealium newInstanceForKey:@"failTest"
                                configuration:config
                                   completion:nil];
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        
        XCTAssert(!success, "Valid mobile.html returned when none should have.");
        
        [e fulfill];
        
        
    }];
    
    [self waitForExpectationsWithTimeout:3.0
                                 handler:nil];
    
}

- (void) testCreateSingleInstance {
    
    [Tealium destroyInstanceForKey:@"instance1"];

    XCTestExpectation *expectation = [self expectationWithDescription:@"singleInstance"];
    
    __block Tealium *instance1;
    __block BOOL alreadyInitialized = NO;
    
    [self measureBlock:^{
        
      instance1 = [Tealium newInstanceForKey:@"instance1" configuration:[TEALTestHelper liveConfig] completion:^(BOOL success, NSError * _Nullable error) {
          
          if (!alreadyInitialized){
              alreadyInitialized = YES;
              [expectation fulfill];
          }
          
          XCTAssert(success, @"Single instance test failed.");
          XCTAssert(!error, @"Error detected in valid config startup: %@", error);
          
        }];
                              
    }];


    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    
    XCTAssertTrue(instance1, @"Instance1 was not initialized.");
}

#pragma mark - instanceForKey: TESTS

- (void) testCreateMultipleInstances {

#warning Update to use the completion blocks
    
    [Tealium destroyInstanceForKey:@"instance1"];
    [Tealium destroyInstanceForKey:@"instance2"];
    [Tealium destroyInstanceForKey:@"instance3"];

    
    TEALConfiguration *config1 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    [Tealium newInstanceForKey:@"instance1" configuration:config1];
    
    
    TEALConfiguration *config2 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                            profile:@"ios"
                                                                        environment:@"dev"];
    [Tealium newInstanceForKey:@"instance2" configuration:config2];
    
    TEALConfiguration *config3 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                     profile:@"ios-demo"
                                                                 environment:@"dev"];
    [Tealium newInstanceForKey:@"instance3" configuration:config3];

    
    Tealium *instance1 = [Tealium instanceForKey:@"instance1"];
    Tealium *instance2 = [Tealium instanceForKey:@"instance2"];
    Tealium *instance3 = [Tealium instanceForKey:@"instance3"];
    
    XCTAssertTrue(instance1, @"Instance1 was not initialized.");
    XCTAssertTrue(instance2, @"Instance2 was not initialized.");
    XCTAssertTrue(instance3, @"Instance3 was not initialized.");
    
}

#pragma mark - destoryInstanceForKey: TESTS

- (void) testDestroyInstance {

    [Tealium destroyInstanceForKey:@"instanceD"];

    [Tealium newInstanceForKey:@"instanceD" configuration:[TEALTestHelper liveConfig]];
    
    [Tealium destroyInstanceForKey:@"instanceD"];
    
    XCTAssertFalse([Tealium instanceForKey:@"instanceD"], @"Instance was not destroyed.");
    
}

- (void) testDestroyOneInstanceAmongMany {
    
    [Tealium destroyInstanceForKey:@"testDisableInstance"];
    [Tealium destroyInstanceForKey:@"instance1"];
    [Tealium destroyInstanceForKey:@"instance2"];
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    [Tealium newInstanceForKey:@"testDisableInstance" configuration:config];
    
    TEALConfiguration *config2 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"ios"
                                                                environment:@"dev"];
    [Tealium newInstanceForKey:@"instance1" configuration:config2];
    
    TEALConfiguration *config3 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"ios-demo"
                                                                environment:@"dev"];
    [Tealium newInstanceForKey:@"instance2" configuration:config3];
    
    Tealium *instanceD = [Tealium instanceForKey:@"testDisableInstance"];
    
    Tealium *instance1 = [Tealium instanceForKey:@"instance1"];
    
    Tealium *instance2 = [Tealium instanceForKey:@"instance2"];
    
    [Tealium destroyInstanceForKey:@"testDisableInstance"];
    
    Tealium *instanceDCheck = [Tealium instanceForKey:@"testDisableInstance"];
    
    NSLog(@"%s instanceD: %@", __FUNCTION__, instanceD);
    
    XCTAssertFalse(instanceDCheck, @"Instance was not destroyed.");
    XCTAssertTrue(instance1, @"Instance1 was not initialized.");
    XCTAssertTrue(instance2, @"Instance2 was not initialized.");
    
}

#pragma mark - delegate & setDelegate: TESTS

- (void) testSetAndRemoveDelegate {
    
    [self useLibraryInstanceWithConfig:[TEALTestHelper liveConfig]];
    
    [self.library setDelegate:self];
    
    XCTAssertTrue([self.library delegate] == self, @"Delegate did not set to test object.");
    
    [self.library setDelegate:nil];
    
    XCTAssertFalse([self.library delegate], @"Delegate did not clear.");
}

- (void) testUnimplementedDelegateMethods {
    
    [self useLibraryInstanceWithConfig:[TEALTestHelper liveConfig]];
    
    TealiumDelegateTestObject *testDelegate = [TealiumDelegateTestObject new];
    
    [self.library setDelegate:testDelegate];
    
    [self.library trackEventWithTitle:@"testCall" dataSources:nil];
    
    id <TealiumDelegate> delegate = [self.library delegate];
    
    XCTAssertTrue(delegate == testDelegate, @"testDelegate did not take.");
    
    // This will cause a crash if the optional delegates are not trully optional
}

- (void) testSuccessfulDidUpdatePublishSettings {
    
    [self useLibraryInstanceWithConfig:[TEALTestHelper configFromTestHTMLFile:@"no_minutes_between_refresh"]];
    
    XCTestExpectation * fetchExpectation = [self expectationWithDescription:@"fetchComplete"];
    
    __block BOOL success;
    __block NSError *error;
    
    __block typeof(self) __weak weakSelf = self;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL fetchSuccess, NSError * _Nullable fetchError) {
        
        success = fetchSuccess;
        
        error = fetchError;
        
        if (success){
            [weakSelf.library.delegate tealiumInstanceDidUpdatePublishSettings:weakSelf.library];
        }
        
        [fetchExpectation fulfill];
        
    }];
    
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    XCTAssertTrue(success, @"Did not successfully fetch settings");
    
    XCTAssertTrue(!error, @"Unexpected error: %@", error);
    
    XCTAssertTrue(self.didUpdate, "No update found");
    
}

- (void) testFailingDidUpdatePublishSettings {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"ios-no-mls-no-mps"
                                                                environment:@"dev"];
    
    [self useLibraryInstanceWithConfig:config];
    
    
    XCTestExpectation * fetchExpectation = [self expectationWithDescription:@"fetchComplete"];

    __block BOOL fetchSuccess = NO;
    
    __block NSError *fetchError = nil;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        fetchSuccess = success;
        
        fetchError = error;

        [fetchExpectation fulfill];
        
        
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    XCTAssertTrue(!fetchSuccess, "Invalid mobile.html returned non-existent account-profile.");
    
    XCTAssertTrue(fetchError, "Error expected was not received.");
    
    XCTAssertTrue(!self.didUpdate, "No update found");
}

#pragma mark - trackEventWithTitle:dataSources & trackViewWithTitle:dataSources: TESTS

// Track events + views are tested in specific dispatch services

#pragma mark - volatileDataSourcesCopy & addVolatileDataSources: & removeVolatileDataSourcesForKeys: TESTS

- (void) testAddAndRemoveVolatileDataSource {
    
    __block BOOL isReady = NO;
    
    Tealium *instance = [Tealium newInstanceForKey:self.description
                                     configuration:[TEALTestHelper liveConfig]
                                        completion:^(BOOL success, NSError * _Nullable error) {
                                            
                                            if (error){
                                                NSLog(@"%s error:%@", __FUNCTION__, error);
                                            }
                                            
                                            isReady = YES;
                                            
                                        }];
    
    NSDictionary *testDataSources = [self stringDataSources];
    
    [self waitFor:&isReady timeout:1.0];
    
    isReady = NO;
    
    [instance addVolatileDataSources:testDataSources];
    
    // There will be a short delay here on this thread as the above method is
    // sent to the end of the Tealium BG serial queue
    [self waitFor:&isReady timeout:1.0];
    
    NSDictionary *dataSourcesRetrieved = [instance volatileDataSourcesCopy];
    
    XCTAssertTrue(dataSourcesRetrieved[TEAL_TEST_DATASOURCE_KEY], @"volatile data was not added.");
    
    XCTAssertTrue([dataSourcesRetrieved[TEAL_TEST_DATASOURCE_KEY] isEqualToString:TEAL_TEST_DATASOURCE_STRING_VALUE], @"volatile data was not added.");
    
    XCTAssertTrue([dataSourcesRetrieved isEqualToDictionary:testDataSources], @"volatile data sources %@ did not match test data sources: %@", dataSourcesRetrieved, testDataSources);
    
    [instance removeVolatileDataSourcesForKeys:@[TEAL_TEST_DATASOURCE_KEY]];
    
    // No callback to flip the flag, so we'll always timeout
    [self waitFor:&isReady timeout:0.5];
    
    // There will be a short delay here on this thread as the above method is
    // sent to the end of the Tealium BG serial queue
    
    XCTAssertTrue(![instance volatileDataSourcesCopy][TEAL_TEST_DATASOURCE_KEY], @"volatile data was not removed.");
    
    XCTAssertTrue([dataSourcesRetrieved isEqualToDictionary:testDataSources], @"volatile data sources %@ did not match test data sources: %@", dataSourcesRetrieved, testDataSources);
    
}

#pragma mark - persistentDataSourcesCopy & addPersistentDataSources: & removePersistentDataSourcesForKeys: TESTS

- (void) testAddAndRemovePersistentDataSources {
    
    [self useLibraryInstanceWithConfig:[TEALTestHelper liveConfig]];
    
    NSDictionary *testData = [self stringDataSources];
    
    [self.library addPersistentDataSources:testData];
    
    __block BOOL isAddReady = NO;
    
    // No callback to flip the flag, so we'll always timeout
    
    [self waitFor:&isAddReady timeout:0.5];
    
    NSDictionary *dataSourcesRetrieved = [self.library persistentDataSourcesCopy];
    
    XCTAssertTrue([dataSourcesRetrieved[TEAL_TEST_DATASOURCE_KEY] isEqualToString:TEAL_TEST_DATASOURCE_STRING_VALUE], @"persistent data was not added.");
    
    [self.library removePersistentDataSourcesForKeys:@[TEAL_TEST_DATASOURCE_KEY]];
    
    __block BOOL isRemoveReady = NO;
    
    // No callback to flip the flag, so we'll always timeout
    
    [self waitFor:&isRemoveReady timeout:0.5];
    
    // There will be a short delay here on this thread as the above method is
    // sent to the end of the Tealium BG serial queue
    
    XCTAssertTrue(![self.library persistentDataSourcesCopy][TEAL_TEST_DATASOURCE_KEY], @"volatile data was not removed.");
    
}


#pragma mark - LIBRARY DELEGATES

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
        NSLog(@"%s ", __FUNCTION__);
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
        NSLog(@"%s ", __FUNCTION__);
}

- (BOOL) tealium:(Tealium *)tealium shouldDropDispatch:(TEALDispatch *)dispatch {

        NSLog(@"%s ", __FUNCTION__);
    
    return self.shouldDrop;
}

- (BOOL) tealium:(Tealium *)tealium shouldQueueDispatch:(TEALDispatch *)dispatch {
    
        NSLog(@"%s ", __FUNCTION__);
    
    return self.shouldQueue;
}

- (void) tealiumInstanceDidUpdatePublishSettings:(Tealium *)tealium {
    
    NSLog(@"%s ", __FUNCTION__);
    
    self.didUpdate = YES;
}

#pragma mark - WebView Tests

//- (void) testSharedInstanceDefaultWebView {
//    // Default is no tag management so webview should not be initialized
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                    profile:@"demo"
//                                                                environment:@"dev"];
//    
//    [self enableSharedInstanceWithConfiguration:config];
//
//    XCTAssertTrue(![[Tealium instanceForKey:@"test"] webView], @"SharedInstance webview was not initialized when it should not have been.");
//
//}
//
//- (void) testSharedInstanceEnableTagManagmentWebView {
//    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"tagmanagement_ON" ofType:@"html"];
//    
//    
//    // Default is no tag management so webview should not be initialized
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                    profile:@"demo"
//                                                                environment:@"dev"];
//    
//    NSString *encoded = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    config.overridePublishSettingsURL = [NSString stringWithFormat:@"file://%@", encoded];
//    config.logLevel = TEALLogLevelVerbose;
//    [self enableSharedInstanceWithConfiguration:config];
//    
//    XCTAssertTrue(![[Tealium instanceForKey:@"test"] webView], @"SharedInstance webview was not initialized when it should have been.");
//    
//}
//
//- (void) testSharedInstanceDisableTagManagmentWebView {
//    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"tagmanagement_OFF" ofType:@"html"];
//    
//    // Default is no tag management so webview should not be initialized
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                    profile:@"demo"
//                                                                environment:@"dev"];
//    NSString *encoded = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    config.overridePublishSettingsURL = [NSString stringWithFormat:@"file://%@", encoded];
//    config.logLevel = TEALLogLevelVerbose;
//    [self enableSharedInstanceWithConfiguration:config];
//    
//    XCTAssertTrue(![[Tealium instanceForKey:@"test"] webView], @"SharedInstance webview was initialized when it should not have been.");
//    
//}

@end
