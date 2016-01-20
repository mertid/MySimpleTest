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

@interface TealiumTests : XCTestCase <TealiumDelegate>

@property (nonatomic) BOOL shouldQueue;
@property (nonatomic) BOOL shouldDrop;
@property (nonatomic) BOOL didUpdate;
@property (nonatomic, strong) Tealium *library;

@end

@implementation TealiumTests

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
    
    [Tealium destroyInstanceForKey:self.description];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"setupLiveInstance"];
    
    self.library = [Tealium newInstanceForKey:self.description
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


#pragma mark - PUBLIC APIs TESTS

- (void) testCreateInstanceWithMissingConfigurationData {
    
    [Tealium destroyInstanceForKey:@"failTest"];

    // All empty
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:nil
                                                                    profile:nil
                                                                environment:nil];
    
    Tealium *instance = [Tealium newInstanceForKey:@"failTest" configuration:config];
    
    XCTAssertFalse(instance, @"Invalid Configuration initialized library instance.");
    
    
    // Account empty
    TEALConfiguration *configB = [TEALConfiguration configurationWithAccount:nil
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    Tealium *instanceB = [Tealium newInstanceForKey:@"failTest" configuration:configB];
    
    XCTAssertFalse(instanceB, @"Missing account Configuration initialized library instance.");
    
    TEALConfiguration *configB2 = [TEALConfiguration configurationWithAccount:@""
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    Tealium *instanceB2 = [Tealium newInstanceForKey:@"failTest" configuration:configB2];
    
    XCTAssertFalse(instanceB2, @"Nil account Configuration initialized library instance.");
    
    
    // Profile empty
    TEALConfiguration *configC = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:nil
                                                                environment:@"dev"];
    
    Tealium *instanceC = [Tealium newInstanceForKey:@"failTest" configuration:configC];
    
    XCTAssertFalse(instanceC, @"Missing profile Configuration initialized library instance.");
    
    
    TEALConfiguration *configC2 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@" "
                                                                environment:@"dev"];
    
    Tealium *instanceC2 = [Tealium newInstanceForKey:@"failTest" configuration:configC2];
    
    XCTAssertFalse(instanceC2, @"Blank profile Configuration initialized library instance.");
    
    
    
    // Environment empty
    TEALConfiguration *configD = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:nil];
    
    Tealium *instanceD = [Tealium newInstanceForKey:@"failTest" configuration:configD];
    
    XCTAssertFalse(instanceD, @"Missing environment Configuration initialized library instance.");
    
    TEALConfiguration *configD2 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"   "];
    
    Tealium *instanceD2 = [Tealium newInstanceForKey:@"failTest" configuration:configD2];
    
    XCTAssertFalse(instanceD2, @"blank environment Configuration initialized library instance.");
}

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

#pragma mark - DELEGATE TESTS

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
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        XCTAssertTrue(success, "Valid mobile.html did not return as expected.");
        
        if (success){
            [self.library.delegate tealiumInstanceDidUpdatePublishSettings:self.library];
        }
        
        [fetchExpectation fulfill];
        
    }];
    
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    XCTAssertTrue(self.didUpdate, "No update found");
    
}

- (void) testFailingDidUpdatePublishSettings {
    
    [Tealium destroyInstanceForKey:@"failSettingsTest"];
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"failPublishTest"];
    
    XCTestExpectation * fetchExpectation = [self expectationWithDescription:@"fetchComplete"];

    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"ios-no-mls-no-mps"
                                                                environment:@"dev"];
    
    self.library = [Tealium newInstanceForKey:@"failSettingsTest"
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                            
        XCTAssertTrue(success, "Test configuration did not start a valid tealium instance");
        
        [expectation fulfill];
        
    }];
    
    self.library.delegate = self;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        
        XCTAssertTrue(!success, "Invalid mobile.html returned non-existent account-profile.");
        
        XCTAssertTrue(error, "Error expected was not received.");

        [fetchExpectation fulfill];
        
        
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    XCTAssertTrue(!self.didUpdate, "No update found");
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
