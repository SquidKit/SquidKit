//
//  Log
//  SquidKit
//
//  Created by Mike Leavy on 8/15/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation
import UIKit

public enum LogStatus {
    case Always
    case Simulator
    case Never
}

private let _SquidKitLogSharedInstance = Log()

private func stdSwiftPrint(message:Any) {
    print(message)
}

public protocol Loggable {
    func log<T>(@autoclosure output: () -> T?)
}

public protocol UnwrappedLoggable : Loggable {
    func log(values:Any?...)
}

public class Log {
    
    private var logStatus:LogStatus = .Simulator
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
    
    public class var sharedLog:Log {
        get {
            return _SquidKitLogSharedInstance
        }
    }
    
    public class func setLogStatus(status:LogStatus) {
        _SquidKitLogSharedInstance.logStatus = status
    }
    
    public class func print<T>(@autoclosure output:() -> T?) {
        if _SquidKitLogSharedInstance.loggingEnabled {
            if let object = output() {
                stdSwiftPrint(object)
            }
        }
    }
    
    //TODO: REMOVE
    public class func printNewLine() {
        if _SquidKitLogSharedInstance.loggingEnabled {
            print("")
        }
    }
    
    public class func message(@autoclosure output: () -> String?) {
        if _SquidKitLogSharedInstance.loggingEnabled {
            if let message = output() {
                NSLog(message)
            }
        }
    }
    
    public class func simulatorAppBundleURL() {
        #if arch(i386) || arch(x86_64)
            Log.message("Simulator app bundle URL: \(NSBundle.mainBundle().bundleURL)")
        #endif
    }
    
    public class func rect(rect:CGRect, message:String = "") {
        Log.message(message + "rect -> x: \(rect.origin.x); y: \(rect.origin.y); width: \(rect.size.width); height: \(rect.size.height)");
    }
    
    public class func point(point:CGPoint, message:String = "") {
        Log.message(message + "point -> x: \(point.x); y: \(point.y)");
    }
}

extension Log : UnwrappedLoggable {
    public func log<T>(@autoclosure output: () -> T?) {
        Log.print(output)
    }
    
    
    public func log(values:Any?...) {
        var result = ""
        for s in values {
            if let unwrapped = s {
                result = "\(result)" + "\(unwrapped)"
            }
        }
        
        Log.print(result)
    }
}
