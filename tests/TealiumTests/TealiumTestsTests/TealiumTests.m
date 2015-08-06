//
//  TealiumTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Tealium/Tealium.h>
#import "Tealium+PrivateHeader.h"
#import "TEALSettings+PrivateHeader.h"

@interface TealiumTests : XCTestCase

@property (nonatomic, strong) Tealium *library;
@property (nonatomic, strong) TEALConfiguration *configuration;

@end

@implementation TealiumTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.library = nil;
    self.configuration = nil;
    [super tearDown];
}

#pragma mark - Helpers

- (void) enableSharedInstanceWithConfiguration:(TEALConfiguration *) config {
    
    if (!config) {
        config = self.configuration;
    }
    
    XCTestExpectation *finishedLoading = [self expectationWithDescription:@"finishLoadingSharedInstance"];
    
    
    [Tealium sharedInstanceWithConfiguration:config completion:^(BOOL success, NSError *error) {
        [finishedLoading fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        NSLog(@"%s error:%@", __FUNCTION__, error);
    }];
}

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    
    if (!config) {
        config = self.configuration;
    }
    
    
    XCTestExpectation *finishedLoading = [self expectationWithDescription:@"finishLoadingInstance"];
    
    self.library = [Tealium instanceWithConfiguration:config];
    [self.library instanceWithConfiguration:config
                          completion:^(BOOL success, NSError *error) {
                              [finishedLoading fulfill];
                          }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        NSLog(@"%s error:%@", __FUNCTION__, error);
    }];
    
}

#pragma mark - PUBLIC APIS TESTS

- (void) testEnableInstanceAndSharedInstance {
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    [self enableSharedInstanceWithConfiguration:config];
    
    TEALConfiguration *configInstance = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                            profile:@"ios"
                                                                        environment:@"dev"];
    [self enableLibraryWithConfiguration:configInstance];
    
    XCTAssertTrue([Tealium sharedInstance], @"SharedInstance was not initialized.");
    XCTAssertTrue(self.library, @"Library instance was not initialized.");
    
}


#pragma mark - Shared Instance Tests

- (void) testEnableSharedInstance {
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    [self enableSharedInstanceWithConfiguration:config];
    
    XCTAssertTrue([Tealium sharedInstance], @"SharedInstance was not initialized.");
    
}


- (void) testDestroySharedInstance {
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];

    [self enableSharedInstanceWithConfiguration:config];
    [Tealium destroySharedInstance];
    
    XCTAssertTrue(![Tealium sharedInstance], @"SharedInstance was not destroyed.");
}


#pragma mark - WebView Tests

- (void) testSharedInstanceDefaultWebView {
    // Default is no tag management so webview should not be initialized
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    
    [self enableSharedInstanceWithConfiguration:config];

    XCTAssertTrue(![[Tealium sharedInstance] webView], @"SharedInstance webview was not initialized when it should not have been.");

}

- (void) testSharedInstanceEnableTagManagmentWebView {
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"tagmanagement_ON" ofType:@"html"];
    
    
    // Default is no tag management so webview should not be initialized
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    NSString *encoded = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    config.overridePublishSettingsURL = [NSString stringWithFormat:@"file://%@", encoded];
    config.logLevel = TEALLogLevelVerbose;
    [self enableSharedInstanceWithConfiguration:config];
    
    
    XCTAssertTrue(![[Tealium sharedInstance] webView], @"SharedInstance webview was not initialized when it should have been.");
    
}

- (void) testSharedInstanceDisableTagManagmentWebView {
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"tagmanagement_OFF" ofType:@"html"];
    
    
    // Default is no tag management so webview should not be initialized
    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    NSString *encoded = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    config.overridePublishSettingsURL = [NSString stringWithFormat:@"file://%@", encoded];
    config.logLevel = TEALLogLevelVerbose;
    [self enableSharedInstanceWithConfiguration:config];
    
    XCTAssertTrue(![[Tealium sharedInstance] webView], @"SharedInstance webview was initialized when it should not have been.");
    
}

@end
