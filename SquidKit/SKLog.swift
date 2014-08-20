//
//  SKLog.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/15/14.
//  Copyright (c) 2014 SquidStore. All rights reserved.
//

import Foundation

public class SKLog {
    public class func logMessage(message:String?) {
#if arch(i386)
    if (message != nil) {
        NSLog(message!)
    }
#endif
    }
    
    public class func logSimulatorAppBundleURL() {
#if arch(i386)
        SKLog.logMessage("Simulator app bundle URL: \(NSBundle.mainBundle().bundleURL)")
#endif
    }
    
    public class func logRect(rect:CGRect, message:String = "") {
        SKLog.logMessage(message + "rect -> x: \(rect.origin.x); y: \(rect.origin.y); width: \(rect.size.width); height: \(rect.size.height)");
    }
}