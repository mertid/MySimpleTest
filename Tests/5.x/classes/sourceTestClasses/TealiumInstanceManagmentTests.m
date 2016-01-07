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
@property (nonatomic, strong) Tealium *library;

@end

@implementation TealiumTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.shouldDrop = NO;
    self.shouldQueue = NO;
    self.library = nil;
    
    [super tearDown];
}

#pragma mark - HELPERS

- (void) useLiveLibraryInstance {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"setupLiveInstance"];
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       if (error){
                                           NSLog(@"%s error:%@", __FUNCTION__, error);
                                       }
                                       
                                       [expectation fulfill];
                                       
                                   }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}
    
#pragma mark - PUBLIC APIs TESTS

- (void) testCreateInstanceWithMissingConfigurationData {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:nil
                                                                    profile:nil
                                                                environment:nil];
    
    Tealium *instance = [Tealium newInstanceForKey:@"failTest" configuration:config];
    
    XCTAssertFalse(instance, @"Invalid Configuration initialized library instance.");
}

- (void) testCreateInstanceWithConfigurationMissingAccountInfo {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:nil
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    Tealium *instance = [Tealium newInstanceForKey:@"failTest" configuration:config];
    
    XCTAssertFalse(instance, @"Invalid Configuration initialized library instance.");
}

- (void) testCreateInstanceWithConfigurationMissingProfileInfo {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:nil
                                                                environment:@"dev"];
    
    Tealium *instance = [Tealium newInstanceForKey:@"failTest" configuration:config];
    
    XCTAssertFalse(instance, @"Invalid Configuration initialized library instance.");
}

- (void) testCreateInstanceWithConfigurationMissingEnvInfo {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:nil];
    
    Tealium *instance = [Tealium newInstanceForKey:@"failTest" configuration:config];
    
    XCTAssertFalse(instance, @"Invalid Configuration initialized library instance.");
}

- (void) testCreateInstanceWithConfigurationBlankAccountInfo {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@""
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    Tealium *instance = [Tealium newInstanceForKey:@"failTest" configuration:config];
    
    XCTAssertFalse(instance, @"Invalid Configuration initialized library instance.");
}

- (void) testCreateInstanceWithConfigurationBlankProfileInfo {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@" "
                                                                environment:@"dev"];
    
    Tealium *instance = [Tealium newInstanceForKey:@"failTest" configuration:config];
    
    XCTAssertFalse(instance, @"Invalid Configuration initialized library instance.");
}

- (void) testCreateInstanceWithConfigurationBlankEnvInfo {
    
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"   "];
    
    Tealium *instance = [Tealium newInstanceForKey:@"failTest" configuration:config];
    
    XCTAssertFalse(instance, @"Invalid Configuration initialized library instance.");
}

- (void) testCreateSingleInstance {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"singleInstance"];
    
    __block Tealium *instance1;
    __block BOOL alreadyInitialized = NO;
    
    [self measureBlock:^{
        
      instance1 = [Tealium newInstanceForKey:@"instance1" configuration:[TEALTestHelper liveConfig] completion:^(BOOL success, NSError * _Nullable error) {
          
          if (!alreadyInitialized){
              [expectation fulfill];
              alreadyInitialized = YES;
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

    [Tealium newInstanceForKey:@"instanceD" configuration:[TEALTestHelper liveConfig]];
    
    [Tealium destroyInstanceForKey:@"instanceD"];
    
    XCTAssertFalse([Tealium instanceForKey:@"instanceD"], @"Instance was not destroyed.");
    
}

- (void) testDestroyOneInstanceAmongMany {
    
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
    
    [self useLiveLibraryInstance];
    
    [self.library setDelegate:self];
    
    XCTAssertTrue([self.library delegate] == self, @"Delegate did not set to test object.");
    
    [self.library setDelegate:nil];
    
    XCTAssertFalse([self.library delegate], @"Delegate did not clear.");
}

- (void) testUnimplementedDelegateMethods {
    
    [self useLiveLibraryInstance];
    
    TealiumDelegateTestObject *testDelegate = [TealiumDelegateTestObject new];
    
    [self.library setDelegate:testDelegate];
    
    [self.library trackEventWithTitle:@"testCall" dataSources:nil];
    
    id <TealiumDelegate> delegate = [self.library delegate];
    
    XCTAssertTrue(delegate == testDelegate, @"testDelegate did not take.");
    
    // This will cause a crash if the optional delegates are not trully optional
}


#pragma mark - LIBRARY DELEGATES

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
        NSLog(@"%s ", __FUNCTION__);
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
        NSLog(@"%s <# message #>", __FUNCTION__);
}

- (BOOL) tealium:(Tealium *)tealium shouldDropDispatch:(TEALDispatch *)dispatch {

        NSLog(@"%s ", __FUNCTION__);
    
    return self.shouldDrop;
}

- (BOOL) tealium:(Tealium *)tealium shouldQueueDispatch:(TEALDispatch *)dispatch {
    
        NSLog(@"%s ", __FUNCTION__);
    
    return self.shouldQueue;
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
