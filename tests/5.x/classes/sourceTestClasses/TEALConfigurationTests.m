//
//  TealiumCollectTests.m
//  CollectTests
//
//  Created by George Webster on 6/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "Tealium+PrivateHeader.h"
#import "TEALSettings.h"

@interface TealiumConfigurationsTests : XCTestCase

@property (strong) Tealium *library;
@property (strong) TEALConfiguration *configuration;

@end

@implementation TealiumConfigurationsTests

- (void) setUp {
    [super setUp];
    
}

- (void) tearDown {
    
    self.library = nil;
    self.configuration = nil;
    
    [super tearDown];
}

#pragma mark - Helpers

//- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
//    
//    
//    if (!config) {
//        config = self.configuration;
//    }
//
//    XCTestExpectation *finishedLoading = [self expectationWithDescription:@"finishLoading"];
//    
//    self.library = [Tealium instanceWithConfiguration:config];
//    [self.library instanceWithConfiguration:config
//                          completion:^(BOOL success, NSError *error) {
//                              [finishedLoading fulfill];
//                          }];
//    
//    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
//        NSLog(@"%s error:%@", __FUNCTION__, error);
//    }];
//    
//}
//
//#pragma mark - ACCOUNT PROFILE ENV TESTS
//

- (void) testAnything {
    XCTFail(@"No tests actually implemented yet");
}

//- (void) testNilAccount {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:nil
//                                                                    profile:@"demo"
//                                                                environment:@"dev"];
//    [self enableLibraryWithConfiguration:self.configuration];
//
//    XCTAssertTrue(!self.library.enabled, @"Library should have been disabled.");
//
//}
//
//- (void) testBlankAccount {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"  "
//                                                                    profile:@"demo"
//                                                                environment:@"dev"];
//    [self enableLibraryWithConfiguration:self.configuration];
//    
//    
//    XCTAssertTrue(!self.library.enabled, @"Library should have been disabled.");
//    
//}
//
//- (void) testUpperCaseAccount {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"ACCOUNT"
//                                                             profile:@"demo"
//                                                         environment:@"dev"];
//    [self enableLibraryWithConfiguration:self.configuration];
//    
//    XCTAssertTrue(self.library.enabled, @"Library should have been disabled.");
//    
//    NSString *accountOutput = self.library.settings.account;
//    
//    XCTAssertTrue([accountOutput isEqualToString:@"account"], @"Account name did not lowercase");
//}
//
//- (void) testNilTIQProfile {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                             profile:nil
//                                                         environment:@"dev"];
//    [self enableLibraryWithConfiguration:self.configuration];
//    
//    XCTAssertTrue(!self.library.enabled, @"Library should have been disabled.");
//    
//}
//
//- (void) testBlankTIQProfile {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                             profile:@"  "
//                                                         environment:@"dev"];
//    [self enableLibraryWithConfiguration:self.configuration];
//    
//    
//    XCTAssertTrue(!self.library.enabled, @"Library should have been disabled.");
//    
//}
//
//- (void) testUpperCaseTIQProfile {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"account"
//                                                             profile:@"DeMo"
//                                                         environment:@"dev"];
//    [self enableLibraryWithConfiguration:self.configuration];
//    
//    XCTAssertTrue(self.library.enabled, @"Library should have been disabled.");
//    
//    NSString *output = self.library.settings.tiqProfile;
//    
//    XCTAssertTrue([output isEqualToString:@"demo"], @"TIQ Profile name did not lowercase");
//}
//
//- (void) testNilEnvironment {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                             profile:@"demo"
//                                                         environment:nil];
//    [self enableLibraryWithConfiguration:self.configuration];
//    
//    XCTAssertTrue(!self.library.enabled, @"Library should have been disabled.");
//    
//}
//
//- (void) testBlankEnvironment {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                             profile:@"demo"
//                                                         environment:@"  "];
//    [self enableLibraryWithConfiguration:self.configuration];
//    
//    
//    XCTAssertTrue(!self.library.enabled, @"Library should have been disabled.");
//    
//}
//
//- (void) testUpperCaseEnvironment {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"account"
//                                                             profile:@"demo"
//                                                         environment:@"DeV"];
//    [self enableLibraryWithConfiguration:self.configuration];
//    
//    XCTAssertTrue(self.library.enabled, @"Library should have been disabled.");
//    
//    NSString *output = self.library.settings.environment;
//    
//    XCTAssertTrue([output isEqualToString:@"dev"], @"Environment name did not lowercase");
//}


#pragma mark - AUTOTRACKING ENABLEMENT TESTS

//
//- (void) testNoMobilePublishSettings {
//    
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                    profile:@"ios-demo"
//                                                                environment:@"dev"];
//    
//    [self enableLibraryWithConfiguration:config];
//    
//    TEALRemoteSettings *settings = [self.library.settingsStore settingsFromConfiguration:config visitorID:@""];
//    
//    [self fetchRemoteSettingsWithSettings:settings];
//    
//    XCTAssertTrue(self.library.settingsStore.currentSettings.status == TEALSettingsStatusInvalid, @"Stored status should be invalid");
//    
//    XCTAssertFalse(self.library.enabled, @"Library should be disabled on invalid settings status");
//}





@end
