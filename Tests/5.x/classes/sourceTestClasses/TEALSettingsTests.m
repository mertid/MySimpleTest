//
//  TEALSettingsTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TEALConfiguration+PrivateHeader.h"

#import "TEALSettings+PrivateHeader.h"

@interface TEALSettingsTests : XCTestCase

@property (nonatomic, strong) TEALSettings *settings;
@property (nonatomic, strong) TEALConfiguration *configuration;

@end

@implementation TEALSettingsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    self.settings = nil;
    self.configuration = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - CONFIGURATIONS

//- (void) testDefaultDispatchURLString {
//    
//    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                              profile:@"demo"
//                                                          environment:@"dev"];
//    
//    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
//    
//    NSString *defaultURLString = @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile&tealium_profile=main";
//    
//    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
//    XCTAssertTrue([[self.settings collectDispatchURLString] isEqualToString:defaultURLString], @"Default dispatch URL returned unexpected string: %@", [self.settings collectDispatchURLString]);
//}

//- (void) testDispatchURLStringOverride {
//    
//    NSString *urlString = @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile&tealium_profile=main&tealium_vid=";
//
//    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                             profile:@"demo"
//                                                         environment:@"dev"];
//    self.configuration.overrideCollectDispatchURL = urlString;
//    
//    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
//    
//    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
//    XCTAssertTrue([[self.settings collectDispatchURLString] isEqualToString:urlString], @"Override dispatch URL string not as expected: %@", [self.settings collectDispatchURLString]);
//}

- (void) testDefaultPublishURL {
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
    
    NSString *defaultURLString = @"https://tags.tiqcdn.com/utag/tealiummobile/demo/dev/mobile.html?";
    
    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
    XCTAssertTrue([[self.settings publishURLString] isEqualToString:defaultURLString], @"Default publish URL string unexpected: %@", [self.settings publishURLString]);
}

- (void) testOverridePublishURL {
    NSString *urlString = @"https://tags.tiqcdn.com/utag/tealiumx/demo/dev/mobile.html?";
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
    self.configuration.overridePublishURL = urlString;
    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
    
    
    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
    XCTAssertTrue([[self.settings publishURLString] isEqualToString:urlString], @"Default publish URL string unexpected: %@", [self.settings publishURLString]);
}


#pragma mark - PUBLISH SETTINGS


@end
