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
    
    XCTestExpectation *finishedLoading = [self expectationWithDescription:@"finishLoading"];
    
    
    [Tealium sharedInstanceWithConfiguration:config completion:^(BOOL success, NSError *error) {
        [finishedLoading fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
        NSLog(@"%s error:%@", __FUNCTION__, error);
    }];
}

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    
    if (!config) {
        config = self.configuration;
    }
    
    XCTestExpectation *finishedLoading = [self expectationWithDescription:@"finishLoading"];
    
    self.library = [Tealium instanceWithConfiguration:config];
    [self.library instanceWithConfiguration:config
                          completion:^(BOOL success, NSError *error) {
                              [finishedLoading fulfill];
                          }];
    
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
        NSLog(@"%s error:%@", __FUNCTION__, error);
    }];
    
}

#pragma mark - TEST PUBLIC APIs

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


@end
