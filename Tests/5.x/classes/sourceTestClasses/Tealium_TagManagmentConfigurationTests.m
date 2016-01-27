//
//  Tealium+TagManagmentTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/11/16.
//
//

#import <XCTest/XCTest.h>

#import "Tealium+PrivateHeader.h"
#import "Tealium+TagManagement.h"
#import "TEALSettings+TagManagement.h"
#import "TEALTagDispatchService.h"
#import "TEALTestHelper.h"


@interface Tealium_TagManagmentConfigurationTests : XCTestCase

@property TEALConfiguration *configuration;
@property TEALSettings *settings;
@property Tealium *library;

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
    self.library = nil;
    [super tearDown];
}

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    [Tealium destroyInstanceForKey:self.description];
    
    if (!config) {
        config = [TEALTestHelper liveConfig];
    }
    
    __block BOOL isReady = NO;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       XCTAssertTrue(success, @"Library failed to finish initializing - error:%@", error);
                                       
                                       isReady = YES;
                                       
                                   }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
    
}

- (BOOL) tagManagementDispatchServiceInArray:(NSArray*)array {
    
    for (id dispatchService in array){
        
        if ([dispatchService isKindOfClass:[TEALTagDispatchService class]]){
            return true;
        }
        
    }
    
    return false;
}
#pragma mark - TESTS


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

- (void) testOverrideTagManagementURL {
    NSString *urlString = @"https://tags.tiqcdn.com/utag/tealiumx/demo/dev/mobile.html?";
    self.configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                             profile:@"demo"
                                                         environment:@"dev"];
    self.configuration.overrideTagManagementURL = urlString;
    self.settings = [[TEALSettings alloc] initWithConfiguration:self.configuration];
    
    
    XCTAssertTrue(self.settings, @"Settings failed to initialize correctly");
    
    NSString *publishURLString = [self.settings tagManagementPublishURLString];

    
    XCTAssertTrue([publishURLString isEqualToString:urlString], @"Default publish URL string unexpected: %@", publishURLString);
}

- (void) testEnabledByPublishSettings {
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];
    
    __block BOOL isNeverReady = NO;
    
    // Adding in a little time buffer to let module spin up
    
    [TEALTestHelper waitFor:&isNeverReady timeout:1.0];
    
    XCTAssertTrue([self.library.settings tagManagementEnabled], @"Tag Management was not enabled by remote publish settings.");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue([self tagManagementDispatchServiceInArray:dispatchServices], @"Tag Management dispatch service NOT found in:%@", dispatchServices);
}

- (void) testDisableByPublishSettings {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"collect_OFF"];
    
    [self enableLibraryWithConfiguration:config];
    
    XCTAssertTrue(![self.library.settings tagManagementEnabled],@"Tag Management enabled when should have been disabled");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue(![self tagManagementDispatchServiceInArray:dispatchServices], @"Tag Management dispatch service found in:%@", dispatchServices);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
