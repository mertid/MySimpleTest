//
//  TealiumCollectTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TEALTestHelper.h"
#import "Tealium+Collect.h"
#import "Tealium+PrivateHeader.h"
#import "TEALSettings.h"
#import "TEALDispatch+PrivateHeader.h"

@interface Tealium_CollectTests : XCTestCase <TealiumDelegate>

@property (nonatomic, strong) Tealium *library;
@property int queueCount;
@property int sentCount;

@end

@implementation Tealium_CollectTests

- (void)setUp {
    [super setUp];
    //...
}

- (void)tearDown {
    self.library = nil;
    self.queueCount = 0;
    self.sentCount = 0;
    
    [super tearDown];
}

#pragma mark - HELPERS

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    if (!config) {
        config = [TEALTestHelper liveConfig];
    }
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
    
    isReady = NO;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        XCTAssertTrue(success, @"Library failed to fetch test settings - error:%@", error);
        
        isReady = YES;
        
    }];
    
}



- (void) fetchRemoteSettingsWithSettings:(TEALSettings *)settings {
    
    __block BOOL isReady = NO;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        isReady = YES;
        
    }];
    
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
}


#pragma mark API TESTS

- (void) testCollectEnabledByPublishSettings {
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"collect_ON" ofType:@"html"];

    XCTAssertTrue(path, @"Path confirmation to test file failed:%@", path);
    
    NSString *pathJSON = [[NSBundle bundleForClass:[self class]] pathForResource:@"collect_ON" ofType:@"json"];
    
    XCTAssertTrue(pathJSON, @"Path confirmation to test file failed:%@", pathJSON);
 
    
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"collect_ON"]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"collectEnable"];
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
       
        XCTAssertTrue(success, @"Unable to fetch remote test settings:%@", error);
        
        [expectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
    
    XCTAssertTrue([self.library.settings collectEnabled], @"Collect was not enabled by remote publish settings.");
    
    
}

//- (void) testCollectDisabledByPublishSettings {
// 
//    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestHTMLFilename:@"collect_OFF"
//                                                                          testClass:self]];
//    
//    XCTAssertFalse([self.library.settings collectEnabled], @"Collect service should not have been enabled per test remote publish setting.");
//}

- (void) testJoinAndLeaveTrace {
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:[TEALTestHelper liveConfig]
                                   completion:^(BOOL success, NSError * _Nullable error) {
      

        isReady = YES;
        
    }];

    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};

    
    NSString *token = @"A1B2C3";
    
    TEALSettings *settings = [self.library settings];
    
    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource should default to nil");
    
    isReady = NO;

    [self.library joinTraceWithToken:token
                          completion:^(BOOL success, NSError * _Nullable error) {
        
        XCTAssertTrue(success, @"Unexpected error in joining trace:%@", error);
                              
        isReady = YES;
        
    }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};

    NSString *traceId = [settings traceID];
    
    XCTAssertTrue(traceId, @"TraceID should have a value - %@ found.", traceId);
    
    XCTAssertTrue([traceId isEqualToString:token], @"TraceID value: %@ should be same as token passed in: %@", traceId, token);
    
    isReady = NO;
    
    [self.library leaveTraceWithCompletion:^(BOOL success, NSError *error) {
        
        isReady = YES;
        
    }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
    
    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource :%@ should now be nil", [settings traceID]);
    
}

#pragma mark - TRACK TESTS

// Track calls require a dispatch service to run, so we're adding track tests to each of the dispatch service modules

- (void) testTrackBatchedEvent {

    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"batch_5"]];
    
    self.library.delegate = self;
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent withPayload:nil];
    
    XCTestExpectation *batchExpectation = [self expectationWithDescription:@"batch"];
    
    __block BOOL fulfilledAlready = NO;
    
    __block typeof(self) __weak weakSelf = self;
    
    // Manually set to match batch_size in above json file
    for (int i = 0; i < 5; i++) {
        
        [self.library trackDispatch:dispatch
                         completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                             
                             XCTAssert(!error, @"Error in track call detected:%@", error);
                             
                             XCTAssertTrue(status == 2, @"Dispatch was not queued as expected:%@", returnDispatch);
                             
                             
                             if (weakSelf.queueCount >= 5 &&
                                 fulfilledAlready == NO){
                                 
                                 fulfilledAlready = YES;
                                 
                                 [batchExpectation fulfill];
                             }

                        }];
    }
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    XCTAssertTrue(self.queueCount == 5, @"5 events did not trigger - events triggered:%i", self.queueCount);
    
    fulfilledAlready = NO;
    
    XCTestExpectation *lastCallExpectation = [self expectationWithDescription:@"batch"];
    
    [self.library trackDispatch:dispatch
                     completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                         
                         XCTAssert(!error, @"Error in track call detected:%@", error);
                         
                         XCTAssertTrue(status == 1, @"Dispatch was not sent as expected:%@", returnDispatch);
                         
                         if (!fulfilledAlready){
                             
                             fulfilledAlready = YES;
                             [lastCallExpectation fulfill];
                             
                         }
                     }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
 
    // Shouldn't the total sent count be 6?
    
    XCTAssertTrue(self.sentCount == 1, @"Sent call not confirmed from delegate.");
}


#pragma mark - TEALIUM DELEGATE

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
    self.queueCount++;
    
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
    self.sentCount++;
}

//- (void) testConfigurationPollingFrequency {
//
//    TEALVisitorProfilePollingFrequency targetFrequency = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
//
//    // default
//    XCTAssertEqual(targetFrequency, self.configuration.pollingFrequency, @"TEALAudienceStreamConfiguration should default to %lu", (unsigned long)targetFrequency);
//
//    targetFrequency = TEALVisitorProfilePollingFrequencyOnRequest;
//
//    self.configuration.pollingFrequency = targetFrequency;
//
//    TEALRemoteSettings *settings = [self.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//
//
//    XCTAssertEqual(targetFrequency, settings.pollingFrequency, @"Settigns Polling Frequency: %lu should be : %lu", (unsigned long)settings.pollingFrequency, (unsigned long)targetFrequency);
//
//
//    targetFrequency = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
//
//    self.configuration.pollingFrequency = targetFrequency;
//
//    settings = [self.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//
//    XCTAssertEqual(targetFrequency, settings.pollingFrequency, @"Settigns Polling Frequency: %lu should be : %lu", (unsigned long)settings.pollingFrequency, (unsigned long)targetFrequency);
//
//}
//
//- (void) enableSharedInstanceWithConfiguration:(TEALConfiguration *) config {
//    
//    if (!config) {
//        config = self.configuration;
//    }
//    
//    __weak XCTestExpectation *finishedLoading = [self expectationWithDescription:@"finishLoadingSharedInstance"];
//    
//
//    [Tealium sharedInstanceWithConfiguration:config completion:^(BOOL success, NSError *error) {
//        
//        if ([[Tealium sharedInstance] isEnabled]){
//            [finishedLoading fulfill];
//        }
//    }];
//    
//    
//    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
//        NSLog(@"%s error:%@", __FUNCTION__, error);
//    }];
//}
//- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
//    
//    
//    if (!config) {
//        config = self.configuration;
//    }
//    
//    
//    XCTestExpectation *finishedLoading = [self expectationWithDescription:@"finishLoadingInstance"];
//    
//    self.library = [Tealium instanceWithConfiguration:config];
//    [self.library instanceWithConfiguration:config
//                                 completion:^(BOOL success, NSError *error) {
//                                     [finishedLoading fulfill];
//                                 }];
//    
//    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
//        NSLog(@"%s error:%@", __FUNCTION__, error);
//    }];
//    
//}
//
//- (void) testSharedInstanceEnableTagManagmentWebView {
//    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"audiencestream_ON" ofType:@"html"];
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
//    XCTAssertTrue(![[Tealium sharedInstance] visitorIDCopy], @"SharedInstance webview was not initialized when it should have been.");
//    
//}
//
//- (void) testSharedInstanceDisableTagManagmentWebView {
//    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"audiencestream_OFF" ofType:@"html"];
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
//    XCTAssertTrue(![[Tealium sharedInstance] visitorIDCopy], @"SharedInstance webview was initialized when it should not have been.");
//    
//}

@end
