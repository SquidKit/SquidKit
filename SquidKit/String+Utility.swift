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
        return guid
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
        return NSURL(string: "tel://\(self.phoneDigitsString())")
    }

    public func validEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return predicate.evaluateWithObject(self)
    }
}

