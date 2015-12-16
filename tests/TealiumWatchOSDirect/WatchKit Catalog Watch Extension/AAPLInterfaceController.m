/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This is the initial interface controller for the WatchKit app. It loads the initial table of the app with data and responds to Handoff launching the WatchKit app.
 */

#import "AAPLInterfaceController.h"
#import "AAPLElementRowController.h"
#import "TealiumWKHelper.h"

@interface AAPLInterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *interfaceTable;

@property (strong, nonatomic) NSArray *elementsList;

@end


@implementation AAPLInterfaceController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [WCSession defaultSession].delegate = self;
        [[WCSession defaultSession] activateSession];
        
        // Initialize variables here.
        // Configure interface objects here.
        
        // Retrieve the data. This could be accessed from the iOS app via a shared container.
        self.elementsList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppData" ofType:@"plist"]];
        
        [self loadTableRows];
        
        [TealiumWKHelper startTracking];
        
        [TealiumWKHelper trackEventWithTitle:@"watchLaunch" dataSources:nil];
        
    }

    return self;
}

- (void)awakeWithContext:(id)context {
        
    NSLog(@"%@ awake with context: %@", self, context);
}

- (void)willActivate {
    // This method is called when the controller is about to be visible to the wearer.
    
//    [TealiumWKHelper trackEventWithTitle:@"wakeWatch" dataSources:nil];

    NSLog(@"%@ will activate", self);
}

- (void)didDeactivate {
    // This method is called when the controller is no longer visible.
    
//    [TealiumWKHelper trackEventWithTitle:@"watchSleep" dataSources:nil];

    NSLog(@"%@ did deactivate", self);
}

- (void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification {
    NSLog(@"Handle action with identifier (Local): %@", identifier);
}

- (void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification {
    NSLog(@"Handle action with identifier (Remote): %@", identifier);
}

- (void)handleUserActivity:(NSDictionary *)userInfo {
    // Use data from the userInfo dictionary passed in to push to the appropriate controller with detailed info.
    [self pushControllerWithName:userInfo[@"controllerName"] context:userInfo[@"detailInfo"]];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    NSDictionary *rowData = self.elementsList[rowIndex];

    NSString *nextInterface = rowData[@"controllerIdentifier"];
    
    [TealiumWKHelper trackEventWithTitle:@"interfaceSelection" dataSources:@{@"nextInterface":nextInterface}];
    
//    NSString *hostReachableWhenProcessed = [[WCSession defaultSession] isReachable]? @"YES":@"NO";
//    
//    [TealiumWKHelper directURLCallTestWithArguments:@{
//                                                      @"nextInterface":nextInterface,
//                                                      @"hostDeviceReachable":hostReachableWhenProcessed,
//                                                      @"timestamp":[NSDate date]
//                                                      }];
    
    [self pushControllerWithName:rowData[@"controllerIdentifier"] context:nil];
}

- (void)loadTableRows {
    [self.interfaceTable setNumberOfRows:self.elementsList.count withRowType:@"default"];
    
    // Create all of the table rows.
    [self.elementsList enumerateObjectsUsingBlock:^(NSDictionary *rowData, NSUInteger idx, BOOL *stop) {
        AAPLElementRowController *elementRow = [self.interfaceTable rowControllerAtIndex:idx];
        
        [elementRow.elementLabel setText:rowData[@"label"]];
    }];
}

- (void) dislayAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    WKAlertAction *action = [WKAlertAction actionWithTitle:@"Cancel"
                                                     style:WKAlertActionStyleDefault
                                                   handler:^{
                                                       
                                                       // any additional handling here
                                                       
                                                   }];
    
    [self presentAlertControllerWithTitle:title
message:message
preferredStyle:WKAlertControllerStyleAlert
                                  actions:@[action]];
    
}

#pragma mark - TEALIUM EXTENSION DELEGATE

/*
 *  Example use of Tealium Extension delegate methods
 */

- (void) tealiumExtensionDidHandoffTrackCall:(NSDictionary *)trackData {
    
    [self dislayAlertWithTitle:@"Tealium Track"
                       message:[trackData description]];
    
}

- (void) tealiumExtensionDidQueueTrackCall:(NSDictionary *)trackData
                         currentQueueCount:(NSUInteger)count{
    
    NSString *message = [NSString stringWithFormat:@"Queue count:%u", count];
    
    [self dislayAlertWithTitle:@"Tealium Queue"
                       message:message];
    
}

- (void) tealiumExtensionTrackCall:(NSDictionary *)trackData didEncounterError:(NSError *)error {
    
    [self dislayAlertWithTitle:@"Tealium Error"
                       message:error.description];
    
}
@end
