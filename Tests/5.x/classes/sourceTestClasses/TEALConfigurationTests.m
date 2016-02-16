//
//  TealiumCollectTests.m
//  CollectTests
//
//  Created by George Webster on 6/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TEALTestHelper.h"
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

// TESTS no longer necessary as arguments will not accept nil

//- (void) testIsValidConfiguration {
//    
//    // All empty
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:nil
//                                                                    profile:nil
//                                                                environment:nil];
//    
//    
//    XCTAssertFalse([TEALConfiguration isValidConfiguration:config], @"Invalid Configuration initialized instance.");
//    
//    
//    // Account empty
//    TEALConfiguration *configB = [TEALConfiguration configurationWithAccount:nil
//                                                                     profile:@"demo"
//                                                                 environment:@"dev"];
//    
//    XCTAssertFalse([TEALConfiguration isValidConfiguration:configB], @"Missing account Configuration initialized instance.");
//    
//    TEALConfiguration *configB2 = [TEALConfiguration configurationWithAccount:@""
//                                                                      profile:@"demo"
//                                                                  environment:@"dev"];
//    
//    
//    XCTAssertFalse([TEALConfiguration isValidConfiguration:configB2], @"Nil account Configuration initialized instance.");
//    
//    
//    // Profile empty
//    TEALConfiguration *configC = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                     profile:nil
//                                                                 environment:@"dev"];
//    
//    XCTAssertFalse([TEALConfiguration isValidConfiguration:configC], @"Missing profile Configuration initialized instance.");
//    
//    
//    TEALConfiguration *configC2 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                      profile:@" "
//                                                                  environment:@"dev"];
//    
//    XCTAssertFalse([TEALConfiguration isValidConfiguration:configC2], @"Blank profile Configuration initialized instance.");
//    
//    
//    // Environment empty
//    TEALConfiguration *configD = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                     profile:@"demo"
//                                                                 environment:nil];
//    
//    
//    XCTAssertFalse([TEALConfiguration isValidConfiguration:configD], @"Missing environment Configuration initialized instance.");
//    
//    TEALConfiguration *configD2 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                      profile:@"demo"
//                                                                  environment:@"   "];
//    
//    XCTAssertFalse([TEALConfiguration isValidConfiguration:configD2], @"blank environment Configuration initialized instance.");
//    
//    
//}
//
//
//- (void) testCreateInstanceWithMissingConfigurationData {
//    
//    [Tealium destroyInstanceForKey:@"failTest"];
//    
//    // All empty
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:nil
//                                                                    profile:nil
//                                                                environment:nil];
//    
//    Tealium *instance = [Tealium newInstanceForKey:@"failTest" configuration:config];
//    
//    XCTAssertFalse(instance, @"Invalid Configuration initialized library instance.");
//    
//    
//    // Account empty
//    TEALConfiguration *configB = [TEALConfiguration configurationWithAccount:nil
//                                                                     profile:@"demo"
//                                                                 environment:@"dev"];
//    
//    Tealium *instanceB = [Tealium newInstanceForKey:@"failTest" configuration:configB];
//    
//    XCTAssertFalse(instanceB, @"Missing account Configuration initialized library instance.");
//    
//    TEALConfiguration *configB2 = [TEALConfiguration configurationWithAccount:@""
//                                                                      profile:@"demo"
//                                                                  environment:@"dev"];
//    
//    Tealium *instanceB2 = [Tealium newInstanceForKey:@"failTest" configuration:configB2];
//    
//    XCTAssertFalse(instanceB2, @"Nil account Configuration initialized library instance.");
//    
//    
//    // Profile empty
//    TEALConfiguration *configC = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                     profile:nil
//                                                                 environment:@"dev"];
//    
//    Tealium *instanceC = [Tealium newInstanceForKey:@"failTest" configuration:configC];
//    
//    XCTAssertFalse(instanceC, @"Missing profile Configuration initialized library instance.");
//    
//    
//    TEALConfiguration *configC2 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                      profile:@" "
//                                                                  environment:@"dev"];
//    
//    Tealium *instanceC2 = [Tealium newInstanceForKey:@"failTest" configuration:configC2];
//    
//    XCTAssertFalse(instanceC2, @"Blank profile Configuration initialized library instance.");
//    
//    
//    
//    // Environment empty
//    TEALConfiguration *configD = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                     profile:@"demo"
//                                                                 environment:nil];
//    
//    Tealium *instanceD = [Tealium newInstanceForKey:@"failTest" configuration:configD];
//    
//    XCTAssertFalse(instanceD, @"Missing environment Configuration initialized library instance.");
//    
//    TEALConfiguration *configD2 = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                      profile:@"demo"
//                                                                  environment:@"   "];
//    
//    Tealium *instanceD2 = [Tealium newInstanceForKey:@"failTest" configuration:configD2];
//    
//    XCTAssertFalse(instanceD2, @"blank environment Configuration initialized library instance.");
//}


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
