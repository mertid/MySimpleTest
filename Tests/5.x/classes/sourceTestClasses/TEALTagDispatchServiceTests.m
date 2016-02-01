//
//  TEALTagDispatchServiceTests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/25/16.
//
//

#import <XCTest/XCTest.h>

#import "TEALTagDispatchService.h"
#import "TEALOperationManager.h"
#import "TEALRemoteCommandManager.h"

@interface TEALTagDispatchServiceTests : XCTestCase

@property TEALTagDispatchService *service;
@property TEALOperationManager *operationManager;

@end

@implementation TEALTagDispatchServiceTests

- (void)setUp {
    [super setUp];
    
    self.operationManager = [[TEALOperationManager alloc] initWithInstanceID:@"testTagDispatchService"];
    self.service = [[TEALTagDispatchService alloc] initWithPublishURLString:[self publishURLString] operationManager:self.operationManager];
}

- (void)tearDown {
    self.service = nil;
    self.operationManager = nil;
    [super tearDown];
}

- (NSString *) publishURLString {
    
    return @"https://www.tealium.com";
}

- (NSString *) tagBridgeCommandString {

    return @"window.open('tealium://test?request=' + encodeURIComponent(JSON.stringify({config : {response_id : \"testCommand\"},payload : {testKey : \"testValue\"}})), '_self');";

}


//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
