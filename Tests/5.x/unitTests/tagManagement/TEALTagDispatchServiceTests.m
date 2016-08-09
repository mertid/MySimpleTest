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

@interface TEALTagDispatchServiceTests : XCTestCase <TEALTagDispatchServiceDelegate>

@property TEALTagDispatchService *service;
@property TEALOperationManager *operationManager;
@property XCTestExpectation *asyncExpectation;

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
    self.asyncExpectation = nil;
    [super tearDown];
}

- (NSString *) publishURLString {
    
    return @"https://www.tealium.com";
}

- (NSString *) tagBridgeCommandString {

    return @"window.open('tealium://test?request=' + encodeURIComponent(JSON.stringify({config : {response_id : \"testCommand\"},payload : {testKey : \"testValue\"}})), '_self');";

}

- (void) testWebViewReadyCallbackSuccess {
    
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    
    NSString *filePath = [testBundle pathForResource:@"tealiummobile_demo_dev" ofType:@"webarchive"];

    self.asyncExpectation = [self expectationWithDescription:@"webViewReady_success"];
    
    TEALOperationManager *opsManager = [[TEALOperationManager alloc] initWithInstanceID:@"testSuccess"];
    
    TEALTagDispatchService *service = [[TEALTagDispatchService alloc] initWithPublishURLString:filePath
                                                                              operationManager:opsManager];
    
    [service setDelegate:self];
    
    [service setup];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(service.status == TEALDispatchNetworkServiceStatusReady, @"service not ready.");
    
}


//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

#pragma mark - TEALTAGDISPATCH SERVICE DELEGATE

- (BOOL) tagDispatchServiceShouldPermitRequest:(NSURLRequest *)request webView:(id)webView {
    
    return true;
}

- (void) tagDispatchServiceWebViewReady:(id)webView {
    
    NSLog(@"%s webViewReady: %@", __FUNCTION__, webView);
    
    [self.asyncExpectation fulfill];
    
}

- (void) tagDispatchServiceWebView:(id)webView encounteredError:(NSError *)error {
    
    NSLog(@"%s webView encountered error:%@", __FUNCTION__, error);
    
}

- (void) tagDispatchServiceWebView:(id)webView processedCommandResponse:(TEALRemoteCommandResponse *)response {
    
}

@end
