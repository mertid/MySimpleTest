//
//  TealiumCollectTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TealiumDelegate.h"
#import "TEALTestHelper.h"
#import "Tealium+Collect.h"
#import "TEALConfiguration+Collect.h"
#import "Tealium+PrivateHeader.h"
#import "TEALSettings.h"
#import "TEALSettings+Collect.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALCollectDispatchService.h"
#import "TEALS2SLegacyDispatchService.h"

@interface Tealium_CollectConfigurationTests : XCTestCase <TealiumDelegate>

@property (nonatomic, strong) Tealium *library;
@property int queueCount;
@property int sentCount;
@property BOOL didFetch;

@end

@implementation Tealium_CollectConfigurationTests

- (void)setUp {
    [super setUp];
    self.didFetch = NO;
    self.queueCount = 0;
    self.sentCount = 0;
    //...
}

- (void)tearDown {
    self.library = nil;

    
    [super tearDown];
}

#pragma mark - HELPERS

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    [Tealium destroyInstanceForKey:self.description];
    
    if (!config) {
        config = [TEALTestHelper liveConfig];
    }
    
    __block BOOL isReady = NO;
    
    __block BOOL initSuccess = NO;
    
    __block NSError *initError = nil;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       initSuccess = success;
                                       initError = error;
                                       

                                       isReady = YES;
                                       
                                   }];
    
    [self.library setDelegate:self];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
    
    XCTAssertTrue(initSuccess, @"Library failed to finish initializing");
    
    XCTAssertTrue(!initError, @"Error encountered: %@", initError);

    
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

- (void) testDefaultS2SLegacyDispatchURL {
    
    /*
     Sample encoded output for account - tealiummobile
     
     @"https://datacloud.tealiumiq.com/tealiummobile/main/8/i.gif?data=%7B%22data%22%3A%7B%22device_battery_percent%22%3A%22-100%22,%22link_id%22%3A%22launch%22,%22event_name%22%3A%22mobile_link%22,%22app_name%22%3A%22UIKitCatalog%22,%22device_os_version%22%3A%229.0%22,%22app_version%22%3A%2212.0%22,%22device_language%22%3A%22en-US%22,%22connection_type%22%3A%22wifi%22,%22timestamp_offset%22%3A%22-8%22,%22library_version%22%3A%225.0.0%22,%22uuid%22%3A%22749C7B66-65E5-49A3-83EB-5F61D5E523B9%22,%22device_ischarging%22%3A%22false%22,%22origin%22%3A%22mobile%22,%22timestamp_local%22%3A%222016-02-10T07%3A07%3A40%22,%22visitor_id%22%3A%22749C7B6665E549A383EB5F61D5E523B9%22,%22call_type%22%3A%22link%22,%22was_queued%22%3A%22false%22,%22device_cputype%22%3A%22x86%20%22,%22resolution%22%3A%223x2%22,%22platform%22%3A%22iOS%22,%22dom.domain%22%3A%22tealium.com%22,%22orientation%22%3A%22Portrait%22,%22device_orientation%22%3A%22Portrait%22,%22app_rdns%22%3A%22com.example.apple-samplecode.UIKitCatalog%22,%22timestamp%22%3A%222016-02-10T15%3A07%3A40Z%22,%22os_version%22%3A%229.0%22,%22device_resolution%22%3A%22750x1334%22,%22launches%22%3A1,%22cp.utag_main_v_id%22%3A%22749C7B6665E549A383EB5F61D5E523B9%22,%22device_architecture%22%3A%2264%22,%22timestamp_unix%22%3A%221455116860%22,%22device%22%3A%22Simulator%22%7D%7D"
     */
    
    
    
    
}

- (void) testOverrideS2SLegacyDispatchURL {
    
    NSString *overrideString = @"https://www.test.com";
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"s2s_ON"];
    
    config.overrideS2SLegacyDispatchURL = overrideString;
    
    [self enableLibraryWithConfiguration:config];
    
    NSString *finalString = [self.library.settings s2SLegacyDispatchURLString];
    
    XCTAssertTrue([overrideString isEqualToString:finalString], @"final s2s dispatch url string:%@ did not match test string", finalString);
    
}

#pragma mark - GENERAL TESTS

//test needs update

//- (void) testCollectEnabledByPublishSettings {
//    
//    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"collect_ON"]];
//    
//    __block BOOL isNeverReady = NO;
//    
//    // Adding in a little time buffer to let module spin up
//    
//    [TEALTestHelper waitFor:&isNeverReady timeout:1.0];
//    
//    XCTAssertTrue([self.library.settings collectEnabled], @"Collect was not enabled by remote publish settings.");
//    
//    NSArray *dispatchServices = [self.library currentDispatchServices];
//    
//    XCTAssertTrue(self.didFetch, @"Fetch delegate never called.");
//    
//    XCTAssertTrue(dispatchServices.count == 1, @"Incorrect number of dispatch services were enabled: %@", dispatchServices);
//    
//    XCTAssertTrue([self collectDispatchServiceInArray:dispatchServices], @"Collect dispatch service NOT found in:%@", dispatchServices);
//}

- (void) testCollectDisableByPublishSettings {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"collect_OFF"];
    
    [self enableLibraryWithConfiguration:config];
    
    XCTAssertTrue(![self.library.settings collectEnabled],@"Collect enabled when should have been disabled");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue(![self collectDispatchServiceInArray:dispatchServices], @"Collect dispatch service found in:%@", dispatchServices);
}

//test needs update
//- (void) testS2SEnabledByPublishSettings {
//    
//    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];
//    
//    __block BOOL isNeverReady = NO;
//    
//    // Adding in a little time buffer to let module spin up
//    
//    [TEALTestHelper waitFor:&isNeverReady timeout:1.0];
//    
//    XCTAssertTrue([self.library.settings s2SLegacyEnabled], @"S2S was not enabled by remote publish settings.");
//    
//    NSArray *dispatchServices = [self.library currentDispatchServices];
//    
//    XCTAssertTrue([self s2SLegacyDispatchServiceInArray:dispatchServices], @"S2S dispatch service NOT found in:%@", dispatchServices);
//}

- (void) testS2SDisableByPublishSettings {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"s2s_OFF"];
    
    [self enableLibraryWithConfiguration:config];
    
    XCTAssertTrue(![self.library.settings s2SLegacyEnabled],@"S2S Legacy enabled when should have been disabled");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue(![self s2SLegacyDispatchServiceInArray:dispatchServices], @"S2S Legacy dispatch service found in:%@", dispatchServices);
}


#pragma mark - TRACK TESTS

//- (void) testTrackBatchEvents {
//    
//    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"batch_5"]];
//    
//    XCTAssertTrue([self.library currentDispatchServices].count > 0, @"Collect dispatch service not yet ready - %@", [self.library currentDispatchServices]);
//    
//    XCTestExpectation *e = [self expectationWithDescription:@"queueBatches"];
//    XCTestExpectation *eSent = [self expectationWithDescription:@"sendBatches"];
//    
//    __block int finishedAddingDispatches = 0;
//    __block int finishedSendingDispatches = 0;
//    __block int batchLimit = 5;
//    __block NSError *dispatchError;
//    
//    for (int i = 0; i < batchLimit; i++) {
//        
//        TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent withPayload:@{@"iteration":@(i)}];
//        
//        [self.library trackDispatch:dispatch
//                         completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
//                             
//                             dispatchError = error;
//                             
//                             if (status == TEALDispatchStatusQueued){
//                                 
//                                 finishedAddingDispatches++;
//                                 
//                                 if (finishedAddingDispatches == batchLimit){
//                                     
//                                     [e fulfill];
//                                 }
//                             }
//                             
//                             if (status == TEALDispatchStatusSent){
//                                 
//                                 finishedSendingDispatches++;
//                                 
//                                 if (finishedAddingDispatches == batchLimit){
//                                 
//                                     [eSent fulfill];
//                                 }
//                             }
//                             
//                         }];
//    }
//    
//    [self waitForExpectationsWithTimeout:1.0 handler:nil];
//    
//    XCTAssertTrue(self.didFetch, @"Override fetch settings did not occur.");
//    
//    XCTAssertTrue(!dispatchError, @"Dispatch error encountered: %@", dispatchError);
//    
//    XCTAssertTrue(finishedAddingDispatches == batchLimit - 1, @"%i dispatches were not added to the queue - queued: %i", batchLimit - 1, finishedAddingDispatches);
//    
//    XCTAssertTrue(finishedSendingDispatches == batchLimit, @"%i sent dispatch callbacks not recieved - received: %i", batchLimit, finishedSendingDispatches);
//    
//    XCTAssertTrue(self.queueCount == batchLimit - 1, @"%i events did not queue - instead: %i", (batchLimit -1), self.queueCount);
//    
//    XCTAssertTrue(self.sentCount == batchLimit, @"%i events did not send - instead: %i", batchLimit,self.sentCount);
//    
//    
//}


#pragma mark - TEALIUM DELEGATE

- (void) tealiumInstanceDidUpdatePublishSettings:(Tealium *)tealium {
    
    self.didFetch = YES;
    
}

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
    self.queueCount++;
    
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
    self.sentCount++;
}


@end
