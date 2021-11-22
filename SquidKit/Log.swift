//
//  Log
//  SquidKit
//
//  Created by Mike Leavy on 8/15/14.
//  Copyright © 2017-2019 Squid Store, LLC. All rights reserved.
//

import Foundation
import UIKit

public enum LogStatus {
    case always
    case simulator
    case never
}

private let _SquidKitLogSharedInstance = Log()

private func stdSwiftPrint(_ message:Any) {
    print(message)
}

open class Log {
    
    fileprivate var logStatus: LogStatus = .simulator
    fileprivate var isSimulator: Bool {
        return UIDevice.current.isSimulator
    }
    
    fileprivate var tab: String {
        return useTabs ? "\t" : ""
    }
    
    open var loggingEnabled:Bool {
        switch self.logStatus {
        case .always:
            return true
        case .simulator:
            return self.isSimulator
        case .never:
            return false
        }
    }
    
    open var prefix: String?
    open var postfix: String?
    open var useTabs: Bool = false
    
    fileprivate init() {
        
    }
    
    open class var sharedLogger:Log {
        get {
            return _SquidKitLogSharedInstance
        }
    }
    
    open class func setLogStatus(_ status:LogStatus) {
        _SquidKitLogSharedInstance.logStatus = status
    }
    
    open class func print<T>(_ output:@autoclosure () -> T?) {
        if _SquidKitLogSharedInstance.loggingEnabled {
            if let object = output() {
                stdSwiftPrint(object)
            }
        }
    }
        
    open class func message(_ output: @autoclosure () -> String?) {
        if _SquidKitLogSharedInstance.loggingEnabled {
            if let message = output() {
                NSLog(Log.sharedLogger.formatted(message))
            }
        }
    }
    
    open class func function(_ message: String, file: String? = #file, function: String = #function) {
        var filename = ""
        if let f = file {
            filename = (f as NSString).lastPathComponent + ": "
        }
        
        let logMessage = "\(filename)\(function)\n\(Log.sharedLogger.tab)\(message)"
        Log.message(logMessage)
    }
    
    open class func simulatorAppBundleURL() {
        #if arch(i386) || arch(x86_64)
            Log.message("Simulator app bundle URL: \(Bundle.main.bundleURL)")
        #endif
    }
    
    open class func rect(_ rect:CGRect, message:String = "") {
        Log.message(message + "rect -> x: \(rect.origin.x); y: \(rect.origin.y); width: \(rect.size.width); height: \(rect.size.height)");
    }
    
    open class func point(_ point:CGPoint, message:String = "") {
        Log.message(message + "point -> x: \(point.x); y: \(point.y)");
    }
    
    fileprivate func formatted(_ message: String) -> String {
        let formatted = (prefix ?? "") + tab + message + (postfix ?? "")
        return formatted
    }
}
