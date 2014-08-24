//
//  SKLog.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/15/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation
import UIKit

public enum SKLogStatus {
    case Always
    case Simulator
    case Never
}

private let _SKLogSharedInstance = SKLog()

public class SKLog {
    
    private var logStatus:SKLogStatus = .Always
    private var isSimulator:Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }
    
    var loggingEnabled:Bool {
        switch self.logStatus {
        case .Always:
            return true
        case .Simulator:
            return self.isSimulator
        default:
            return false
        }
    }
    
    private init() {
        
    }
    
    public class func setLogStatus(status:SKLogStatus) {
        _SKLogSharedInstance.logStatus = status
    }
    
    public class func print<T>(object:T) {
        if _SKLogSharedInstance.loggingEnabled {
            println(object)
        }
    }
    
    public class func logMessage(output: @autoclosure() -> String?) {
        if _SKLogSharedInstance.loggingEnabled {
            if let message = output() {
                NSLog(message)
            }
        }
    }
    
    public class func logSimulatorAppBundleURL() {
        #if arch(i386) || arch(x86_64)
            SKLog.logMessage("Simulator app bundle URL: \(NSBundle.mainBundle().bundleURL)")
        #endif
    }
    
    public class func logRect(rect:CGRect, message:String = "") {
        SKLog.logMessage(message + "rect -> x: \(rect.origin.x); y: \(rect.origin.y); width: \(rect.size.width); height: \(rect.size.height)");
    }
    
    public class func logPoint(point:CGPoint, message:String = "") {
        SKLog.logMessage(message + "point -> x: \(point.x); y: \(point.y)");
    }
}
