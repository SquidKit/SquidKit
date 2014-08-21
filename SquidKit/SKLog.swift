//
//  SKLog.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/15/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation
import UIKit

public class SKLog {
    
    public class func logMessage(output: @autoclosure() -> String?) {
        #if arch(i386) || arch(x86_64)
            if let message = output() {
                NSLog(message)
            }
        #endif
    }
    
    public class func logSimulatorAppBundleURL() {
        #if arch(i386) || arch(x86_64)
            SKLog.logMessage("Simulator app bundle URL: \(NSBundle.mainBundle().bundleURL)")
        #endif
    }
    
    public class func logRect(rect:CGRect, message:String = "") {
        SKLog.logMessage(message + "rect -> x: \(rect.origin.x); y: \(rect.origin.y); width: \(rect.size.width); height: \(rect.size.height)");
    }
    
    public class func autoLog(output: @autoclosure() -> String) {
        #if arch(i386)
            output()
        #endif
    }
}
