//
//  TealiumCollectTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TEALTestHelper.h"
#import "Tealium+Collect.h"
#import "TEALConfiguration+Collect.h"
#import "Tealium+PrivateHeader.h"
#import "TEALSettings.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALCollectDispatchService.h"
#import "TEALS2SLegacyDispatchService.h"

@interface Tealium_CollectConfigurationTests : XCTestCase <TealiumDelegate>

@property (nonatomic, strong) Tealium *library;
@property int queueCount;
@property int sentCount;

@end

@implementation Tealium_CollectConfigurationTests

- (void)setUp {
    [super setUp];
    //...
}

- (void)tearDown {
    self.library = nil;
    self.queueCount = 0;
    self.sentCount = 0;
    
    [super tearDown];
}

#pragma mark - HELPERS

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
    
    isReady = NO;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        XCTAssertTrue(!error, @"Library failed to fetch test settings - error:%@", error);
        
        isReady = YES;
        
    }];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}

    
}

- (BOOL) collectDispatchServiceInArray:(NSArray*)array {
    
    for (id dispatchService in array){
        
        if ([dispatchService isKindOfClass:[TEALCollectDispatchService class]]){
            return true;
        }
        
    }
    
    return false;
}

- (BOOL) s2SLegacyDispatchServiceInArray:(NSArray*)array {
    
    for (id dispatchService in array){
        
        if ([dispatchService isKindOfClass:[TEALS2SLegacyDispatchService class]]){
            return true;
        }
        
    }
    
    return false;
}

- (void) fetchRemoteSettingsWithSettings:(TEALSettings *)settings {
    
    __block BOOL isReady = NO;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        isReady = YES;
        
    }];
    
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
}

#pragma mark - CONFIGURATION TESTS

- (void) testOverrideCollectDispatchURLWithVisitorID {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"collect_ON"];
    
    NSString *checkString= @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile-tagbridge&tealium_profile=main&tealium_vid=83D8F6217A29466EBEEF4E97C5D9ADDF";

    config.overrideCollectDispatchURL = checkString;
    
    [self enableLibraryWithConfiguration:config];
    
    NSString *visitorID = [self.library.dataSources visitorIDCopy];

    NSString *finalString = [self.library.settings collectDispatchURLStringForVisitorID:visitorID];
    
    XCTAssertTrue([checkString isEqualToString:finalString], @"final dispatch url string:%@ did not match check string:%@", finalString, checkString);
    
}

- (void) testOverrideCollectDispatchURLWithNOVisitorID {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"collect_ON"];
    
    config.overrideCollectDispatchURL = @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile-tagbridge&tealium_profile=main";
    
    [self enableLibraryWithConfiguration:config];
    
    NSString *visitorID = [self.library.dataSources visitorIDCopy];
    
    NSString *finalString = [self.library.settings collectDispatchURLStringForVisitorID:visitorID];
    
    NSMutableString *checkStringBase = [NSMutableString stringWithFormat:@"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile-tagbridge&tealium_profile=main&tealium_vid="];
    
    NSString *checkString = [checkStringBase stringByAppendingString:visitorID];
    
    XCTAssertTrue([checkString isEqualToString:finalString], @"final dispatch url string:%@ did not match check string:%@", finalString, checkString);
    
}

#pragma mark - GENERAL TESTS

- (void) testCollectEnabledByPublishSettings {
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"collect_ON" ofType:@"html"];

    XCTAssertTrue(path, @"Path confirmation to test file failed:%@", path);
    
    NSString *pathJSON = [[NSBundle bundleForClass:[self class]] pathForResource:@"collect_ON" ofType:@"json"];
    
    XCTAssertTrue(pathJSON, @"Path confirmation to test file failed:%@", pathJSON);
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"collect_ON"]];
    
    __block isNeverReady = NO;
    
    // Adding in a little time buffer to let module spin up
    
    [TEALTestHelper waitFor:&isNeverReady timeout:0.5];
    
    XCTAssertTrue([self.library.settings collectEnabled], @"Collect was not enabled by remote publish settings.");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];

    XCTAssertTrue([self collectDispatchServiceInArray:dispatchServices], @"Collect dispatch service NOT found in:%@", dispatchServices);
}

- (void) testCollectDisableByPublishSettings {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"collect_OFF"];
    
    [self enableLibraryWithConfiguration:config];
    
    XCTAssertTrue(![self.library.settings collectEnabled],@"Collect enabled when should have been disabled");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue(![self collectDispatchServiceInArray:dispatchServices], @"Collect dispatch service found in:%@", dispatchServices);
}

- (void) testS2SEnableByPublishSettings {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"s2s_ON"];
    
    [self enableLibraryWithConfiguration:config];
    
    __block isNeverReady = NO;
    
    // Adding in a little time buffer to let module spin up
    
    [TEALTestHelper waitFor:&isNeverReady timeout:0.5];
    
    XCTAssertTrue([self.library.settings s2SLegacyEnabled],@"S2S disabled when should have been enabled");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue([self s2SLegacyDispatchServiceInArray:dispatchServices], @"S2S Legacy dispatch service NOT found in:%@", dispatchServices);
    
}

- (void) testS2SDisableByPublishSettings {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"s2s_OFF"];
    
    [self enableLibraryWithConfiguration:config];
    
    XCTAssertTrue(![self.library.settings s2SLegacyEnabled],@"S2S Legacy enabled when should have been disabled");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue(![self s2SLegacyDispatchServiceInArray:dispatchServices], @"S2S Legacy dispatch service found in:%@", dispatchServices);
}

//- (void) testJoinAndLeaveTrace {
//    
//    [Tealium destroyInstanceForKey:self.description];
//    
//    __block BOOL isReady = NO;
//    
//    self.library = [Tealium newInstanceForKey:self.description
//                                configuration:[TEALTestHelper liveConfig]
//                                   completion:^(BOOL success, NSError * _Nullable error) {
//      
//
//        isReady = YES;
//        
//    }];
//
//    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
//
//    
//    NSString *token = @"A1B2C3";
//    
//    TEALSettings *settings = [self.library settings];
//    
//    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource should default to nil");
//    
//    isReady = NO;
//
//    [self.library joinTraceWithToken:token
//                          completion:^(BOOL success, NSError * _Nullable error) {
//        
//        XCTAssertTrue(success, @"Unexpected error in joining trace:%@", error);
//                              
//        isReady = YES;
//        
//    }];
//    
//    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
//
//    NSString *traceId = [settings traceID];
//    
//    XCTAssertTrue(traceId, @"TraceID should have a value - %@ found.", traceId);
//    
//    XCTAssertTrue([traceId isEqualToString:token], @"TraceID value: %@ should be same as token passed in: %@", traceId, token);
//    
//    isReady = NO;
//    
//    [self.library leaveTraceWithCompletion:^(BOOL success, NSError *error) {
//        
//        isReady = YES;
//        
//    }];
//    
//    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
//    
//    XCTAssertTrue([settings traceID] == nil, @"TraceID datasource :%@ should now be nil", [settings traceID]);
//    
//}

#pragma mark - TRACK TESTS

// Track calls require a dispatch service to run, so we're adding track tests to each of the dispatch service modules

- (void) testTrackBatchedEvent {

    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"batch_5"]];
    
    self.library.delegate = self;
    
    
    XCTestExpectation *batchExpectation = [self expectationWithDescription:@"batch"];
    
    __block int finishedDispatches = 0;
    
    __block int batchLimit = 5;
    
    // Manually set to match batch_size in above json file
    for (__block int i = 0; i < batchLimit; i++) {
        
        TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent withPayload:@{@"iteration":@(i)}];

        [self.library trackDispatch:dispatch
                         completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull returnDispatch, NSError * _Nullable error) {
                             
             XCTAssert(!error, @"Error in track call detected:%@", error);
             
             finishedDispatches++;
             
             if (finishedDispatches < batchLimit ){
                 XCTAssertTrue(status == 2, @"Dispatch was not queued as expected:%@", returnDispatch);
             }
             
             if (finishedDispatches == batchLimit ){
                 
                 [batchExpectation fulfill];
                 
             }
             
         }];
        
    }
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    // will send upon 5th dispatch
    XCTAssertTrue(self.queueCount == 4, @"5 events did not trigger - events triggered:%i", self.queueCount);
    
    // all 5 should be sent
    XCTAssertTrue(self.sentCount == 5, @"Sent call not confirmed from delegate.");

}


#pragma mark - TEALIUM DELEGATE

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
    self.queueCount++;
    
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
    self.sentCount++;
}

//- (void) testConfigurationPollingFrequency {
//
//    TEALVisitorProfilePollingFrequency targetFrequency = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
//
//    // default
//    XCTAssertEqual(targetFrequency, self.configuration.pollingFrequency, @"TEALAudienceStreamConfiguration should default to %lu", (unsigned long)targetFrequency);
//
//    targetFrequency = TEALVisitorProfilePollingFrequencyOnRequest;
//
//    self.configuration.pollingFrequency = targetFrequency;
//
//    TEALRemoteSettings *settings = [self.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//
//
//    XCTAssertEqual(targetFrequency, settings.pollingFrequency, @"Settigns Polling Frequency: %lu should be : %lu", (unsigned long)settings.pollingFrequency, (unsigned long)targetFrequency);
//
//
//    targetFrequency = TEALVisitorProfilePollingFrequencyAfterEveryEvent;
//
//    self.configuration.pollingFrequency = targetFrequency;
//
//    settings = [self.settingsStore settingsFromConfiguration:self.configuration visitorID:@""];
//
//    XCTAssertEqual(targetFrequency, settings.pollingFrequency, @"Settigns Polling Frequency: %lu should be : %lu", (unsigned long)settings.pollingFrequency, (unsigned long)targetFrequency);
//
//}
//
//- (void) enableSharedInstanceWithConfiguration:(TEALConfiguration *) config {
//    
//    if (!config) {
//        config = self.configuration;
//    }
//    
//    __weak XCTestExpectation *finishedLoading = [self expectationWithDescription:@"finishLoadingSharedInstance"];
//    
//
//    [Tealium sharedInstanceWithConfiguration:config completion:^(BOOL success, NSError *error) {
//        
//        if ([[Tealium sharedInstance] isEnabled]){
//            [finishedLoading fulfill];
//        }
//    }];
//    
//    
//    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
//        NSLog(@"%s error:%@", __FUNCTION__, error);
//    }];
//}
//- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
//    
//    
//    if (!config) {
//        config = self.configuration;
//    }
//    
//    
//    XCTestExpectation *finishedLoading = [self expectationWithDescription:@"finishLoadingInstance"];
//    
//    self.library = [Tealium instanceWithConfiguration:config];
//    [self.library instanceWithConfiguration:config
//                                 completion:^(BOOL success, NSError *error) {
//                                     [finishedLoading fulfill];
//                                 }];
//    
//    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
//        NSLog(@"%s error:%@", __FUNCTION__, error);
//    }];
//    
//}
//
//- (void) testSharedInstanceEnableTagManagmentWebView {
//    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"audiencestream_ON" ofType:@"html"];
//    
//    
//    // Default is no tag management so webview should not be initialized
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                    profile:@"demo"
//                                                                environment:@"dev"];
//    
//    NSString *encoded = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    config.overridePublishSettingsURL = [NSString stringWithFormat:@"file://%@", encoded];
//    config.logLevel = TEALLogLevelVerbose;
//    [self enableSharedInstanceWithConfiguration:config];
//    
//    XCTAssertTrue(![[Tealium sharedInstance] visitorIDCopy], @"SharedInstance webview was not initialized when it should have been.");
//    
//}
//
//- (void) testSharedInstanceDisableTagManagmentWebView {
//    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"audiencestream_OFF" ofType:@"html"];
//    
//    // Default is no tag management so webview should not be initialized
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"tealiummobile"
//                                                                    profile:@"demo"
//                                                                environment:@"dev"];
//    NSString *encoded = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    config.overridePublishSettingsURL = [NSString stringWithFormat:@"file://%@", encoded];
//    config.logLevel = TEALLogLevelVerbose;
//    [self enableSharedInstanceWithConfiguration:config];
//    
//    XCTAssertTrue(![[Tealium sharedInstance] visitorIDCopy], @"SharedInstance webview was initialized when it should not have been.");
//    
//}

@end
