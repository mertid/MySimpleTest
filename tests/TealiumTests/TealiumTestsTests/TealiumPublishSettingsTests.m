//
//  TealiumCollectTests.m
//  CollectTests
//
//  Created by George Webster on 6/4/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <Tealium/Tealium.h>
#import <Tealium/TEALSettings.h>
#import "Tealium+PrivateHeader.h"

@interface TealiumPublishSettingsTests : XCTestCase

@property (strong) Tealium *library;
@property TEALConfiguration *configuration;

@end

@implementation TealiumPublishSettingsTests

- (void) setUp {
    [super setUp];
    
    self.library = [[Tealium alloc] initPrivate];
    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                             profile:@"demo"
//                                                         environment:@"dev"];
}

- (void) tearDown {
    
    [[Tealium sharedInstance] disable];
    self.library = nil;
    self.configuration = nil;
    
    [super tearDown];
}

#pragma mark - Helpers

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    
    // TODO: Hook up to use protocol
    
    if (!config) {
        config = self.configuration;
    }

    __block BOOL isReady = NO;
    
    self.library = [Tealium instanceWithConfiguration:config];
    [self.library setupConfiguration:config
                          completion:^(BOOL success, NSError *error) {
                              isReady = YES;
                          }];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
}

//- (void) fetchRemoteSettingsWithSettings:(TEALRemoteSettings *)settings {
//    
//    self.library.enabled = YES;
//    
//    __block BOOL isReady = NO;
//    
//    [self.library fetchRemoteSettings:settings completion:^(BOOL success, NSError *error) {
//        
//        isReady = YES;
//    }];
//    
//    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
//}

#pragma mark - Test General Configuration / Settings updates

- (void) testNilAccount {
    
    self.configuration = [TEALConfiguration configurationWithAccount:nil
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    [self enableLibraryWithConfiguration:self.configuration];
    
//    [self.library.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//    
//    XCTAssertTrue(!self.library.settingsStore.currentSettings, @"Current settings should not have been initialized.");
    XCTAssertTrue(!self.library.enabled, @"Library should have been disabled.");

}

- (void) testBlankAccount {
    
    self.configuration = [TEALConfiguration configurationWithAccount:@"  "
                                                                    profile:@"demo"
                                                                environment:@"dev"];
    [self enableLibraryWithConfiguration:self.configuration];
    
//    [self.library.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
    
//    XCTAssertTrue(!self.library.settingsStore.currentSettings, @"Current settings should not have been initialized.");
    XCTAssertTrue(!self.library.enabled, @"Library should have been disabled.");
    
//    XCTAssertTrue(self.library.settingsStore.currentSettings.status == TEALSettingsStatusInvalid, @"Stored status should be invalid");
}

- (void) testSettingsStorage {
    
    [self enableLibraryWithConfiguration:nil];
    
//    TEALRemoteSettings *settings = [self.library.settingsStore settingsFromConfiguration:self.configuration
//                                                                         visitorID:@""];
//    
//    [self fetchRemoteSettingsWithSettings:settings];
//    
//    XCTAssertTrue([self.library.settingsStore.currentSettings isEqual:settings], @"saved settings should be same object passed in");
}

//- (void) testInvalidAccount {
//    
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"invalid_tealiummobile"
//                                                                    profile:@"demo"
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

- (void) testValidMPSWithDefaultConfigurationNoTags {
    
    // Library should queue calls 
    
}

#pragma mark - TEST CONFIGURATION OPTIONS




@end
