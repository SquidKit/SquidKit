//
//  String+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/17/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

public extension String {
    
    public static func nonNilString(string:String?, stringForNil:String = "") -> String {
        if let nonNilString = string {
            return nonNilString
        }
        
        return stringForNil
    }

    public static func guid() -> String {
        let uuid:CFUUIDRef = CFUUIDCreate(kCFAllocatorDefault)

        let guid = CFUUIDCreateString(kCFAllocatorDefault, uuid) as NSString
        return guid as! String
    }
    
    public static func deserializeJSON(jsonObject:AnyObject, pretty:Bool) -> String? {
        
        var result:String?
        
        if NSJSONSerialization.isValidJSONObject(jsonObject) {
            let outputStream:NSOutputStream = NSOutputStream.outputStreamToMemory()
            outputStream.open()
            var error:NSError?
            let bytesWritten:Int = NSJSONSerialization.writeJSONObject(jsonObject, toStream: outputStream, options: pretty ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(0), error: &error)
            outputStream.close()
            
            if bytesWritten > 0 {
                if let data:NSData = outputStream.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as? NSData {
                    result = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                }
            }
        }
        
        return result
    }

    public func stringByTrimmingLeadingWhitespace() -> String {
        if let range = self.rangeOfString("^\\s*", options:.RegularExpressionSearch) {
            let result = self.stringByReplacingCharactersInRange(range, withString: "")
            return result
        }
        return self
    }

    public func stringByTrimmingTrailingWhitespace() -> String {
        if let range = self.rangeOfString("\\s*$", options:.RegularExpressionSearch) {
            let result = self.stringByReplacingCharactersInRange(range, withString: "")
            return result
        }
        return self
    }

    public func phoneDigitsString() -> String {
        let characterSet = NSCharacterSet(charactersInString: "()- ")
        let components:NSArray = self.componentsSeparatedByCharactersInSet(characterSet)
        return components.componentsJoinedByString("")
    }

    public func phoneURL() -> NSURL {
        return NSURL(string: "tel://\(self.phoneDigitsString())")!
    }

    public func validEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluateWithObject(self)
    }
    
    
}

