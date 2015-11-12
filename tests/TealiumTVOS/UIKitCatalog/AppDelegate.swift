/*
    Copyright (C) 2015 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The application-specific delegate class.
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /*
        When the user clicks a Top Shelf item, the application will be asked
        to open the associated URL.
    */
    func application(app: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        print("Application launched with URL: \(url)")
        

        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        print("Application didFinishLaunchingWithOptions.")
        
        let config = TEALConfiguration.init(account: "tealiummobile", profile: "demo", environment: "dev")
//        config.useHTTP = true;
//        config.overrideCollectLegacyDispatchURL = "https://httpbin.org/"
        Tealium.newInstanceForKey("tealium", configuration: config)
        
        
        Tealium.instanceForKey("tealium")?.trackEventWithTitle("launched", dataSources: nil)
        
        return true
    }
}
