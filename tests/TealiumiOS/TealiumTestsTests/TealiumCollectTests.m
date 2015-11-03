//
//  TealiumCollectTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Tealium/Tealium.h>
#import <Tealium/Tealium+Collect.h>
#import <Tealium/TEALConfiguration.h>
#import "Tealium+PrivateTestHeader.h"

@interface TealiumCollectTests : XCTestCase

@property (nonatomic, strong) Tealium *library;
@property (nonatomic, strong) TEALConfiguration *configuration;

@end

@implementation TealiumCollectTests

- (void)setUp {
    [super setUp];
    
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.library = nil;
    self.configuration = nil;
    [super tearDown];
}

#pragma mark - HELPERS

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    if (!config) {
        config = self.configuration;
    }
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:@"test"
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
}

- (void) fetchRemoteSettingsWithSettings:(TEALSettings *)settings {
    
    __block BOOL isReady = NO;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        isReady = YES;
        
    }];
    
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
}


#pragma mark TESTS

- (void) testTrace {
    
//    [self enableLibraryWithConfiguration:nil];
//    
//    NSString *token = @"A1B2C3";
//    
//    TEALSettings *settings = [self.library settings];
//    
//    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource should default to nil");
//    
//#warning Where is this old API being pulled from?
//    [self.library joinTraceWithToken:token];
//    
//    XCTAssertTrue([settings traceID] != nil, @"TraceID datasource:%@ should have a value.", [settings traceID]);
//    
//    XCTAssertTrue([[settings traceID] isEqualToString:token], @"TraceID datasource value: %@ should be same as token passed in: %@", settings.traceID, token);
//    
//    [self.library leaveTrace];
//    
//    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource :%@ should now be nil", [settings traceID]);
    
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
