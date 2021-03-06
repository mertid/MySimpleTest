//
//  TealiumHelper.swift
//  Blank+Tealium-Swift
//
//  Created by Jason Koo on 11/16/15.
//  Copyright © 2015 Tealium. All rights reserved.
//

/*
*  Using an abstract class like this is the recommended best practice for
*  utilizing analytics or other third party libraries requiring an event
*  trigger with optional data.
*/
import Foundation
//import TealiumTVOS_Lifecycle


let tealiumInstanceID = "1"

class TealiumHelper : NSObject {
    
    static let _sharedInstance = TealiumHelper()
    
    class func sharedInstance() -> TealiumHelper{
        
        return _sharedInstance
    }
    
    class func startTracking() {
        
        if Tealium.instanceForKey(tealiumInstanceID) != nil {
            return
        }
        
        let config = TEALConfiguration.init(account: "tealiummobile", profile: "collect", environment: "dev")
        
        let tealium = Tealium.newInstanceForKey(tealiumInstanceID, configuration: config)
        
        tealium.setDelegate(sharedInstance())
        
        
    }
    
    class func trackEvent(title: String, dataSources: [String:String]){
        
        Tealium.instanceForKey(tealiumInstanceID)?.trackEventWithTitle(title, dataSources: dataSources)
        
    }
    
    class func trackView(title: String, dataSources: [String:String]){
        
        Tealium.instanceForKey(tealiumInstanceID)?.trackViewWithTitle(title, dataSources: dataSources)
        
    }
    
    class func stopTracking(){
        
        Tealium.destroyInstanceForKey(tealiumInstanceID)
        
    }
}

extension TealiumHelper : TealiumDelegate {
    
    func tealium(tealium: Tealium!, shouldDropDispatch dispatch: TEALDispatch!) -> Bool {
        
        // Add optional tracking suppression logic here - returning true will destroy
        // any processed dispatch so some conditional must eventually return false
        
        return false
    }
    
    func tealium(tealium: Tealium!, shouldQueueDispatch dispatch: TEALDispatch!) -> Bool {
        
        // Add optional queuing / saving logic here - returning true will save
        // a dispatch so some condition must eventually return false.
        
        return false
    }
    
    func tealium(tealium: Tealium!, didQueueDispatch dispatch: TEALDispatch!) {
        
//        print("Did queue dispatch: \(dispatch)")
        
        // Add optional code here to respond to queuing of dispatches.

    }
    
    func tealium(tealium: Tealium!, didSendDispatch dispatch: TEALDispatch!) {
        
//        print("Did send dispatch: \(dispatch)")
        
        // Add optional code here to respond to sent dispatches.

    }
    
    func tealium(tealium: Tealium!, webViewIsReady webView: AnyObject!) {

        // Use this to interact with the Tag Management Dispatcher's webview - available only if Tag Management enabled via remote settings.

        
    }
}
