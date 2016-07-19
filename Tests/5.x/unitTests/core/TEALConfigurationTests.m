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
