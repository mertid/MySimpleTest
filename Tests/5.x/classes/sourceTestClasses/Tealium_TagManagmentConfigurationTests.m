//
//  Tealium+TagManagmentTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/11/16.
//
//

#import <XCTest/XCTest.h>

#import "Tealium+TagManagement.h"


@interface Tealium_TagManagmentConfigurationTests : XCTestCase

@property TEALConfiguration *configuration;
@property TEALSettings *settings;

@end

@implementation Tealium_TagManagmentConfigurationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    self.configuration = nil;
    self.settings = nil;
    
    [super tearDown];
}

- (void) testDefaultPublishURL {
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
    
    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
    
    NSString *defaultURLString = @"https://tags.tiqcdn.com/utag/tealiummobile/demo/dev/mobile.html?";
    
    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
    
    NSString *publishURLString = [self.settings tagManagementPublishURLString];
    
    XCTAssertTrue([publishURLString isEqualToString:defaultURLString], @"Default publish URL string unexpected: %@", publishURLString);
}

- (void) testOverridePublishURL {
    NSString *urlString = @"https://tags.tiqcdn.com/utag/tealiumx/demo/dev/mobile.html?";
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
    self.configuration.overridePublishURL = urlString;
    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
    
    
    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
    
    NSString *publishURLString = [self.settings tagManagementPublishURLString];

    
    XCTAssertTrue([publishURLString isEqualToString:urlString], @"Default publish URL string unexpected: %@", publishURLString);
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
