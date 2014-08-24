//
//  UIColor+Hex.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    
    public class func colorWithHex(hex:UInt32, alpha:Float = -1) -> UIColor {
        return UIColor(red:((CGFloat)((hex & 0xFF0000) >> 16))/255.0,
            green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0,
            blue: ((CGFloat)(hex & 0xFF))/255.0,
            alpha: (CGFloat)(alpha >= 0 ? alpha : 1))
    }
    
    public class func colorWithHexString(hexString:String, alpha:Float = -1) -> UIColor? {
        var s:NSMutableString = NSMutableString.stringWithString(hexString)
        s.replaceOccurrencesOfString("#", withString: "", options:.LiteralSearch, range: NSRange(location: 0, length: s.length))
        s.replaceOccurrencesOfString("0x", withString: "", options:.CaseInsensitiveSearch, range: NSRange(location: 0, length: s.length))
        CFStringTrimWhitespace(s as CFMutableStringRef);
        

        // allow strings > 6 character, additional characters assumed to be comment or descriptor

        if s.length < 6 {
            return nil
        }
                
        let redString = s.substringToIndex(2)
        let greenString = s.substringWithRange(NSRange(location: 2, length: 2))
        let blueString = s.substringWithRange(NSRange(location: 4, length: 2))
        
        var red:UInt32 = 0
        var green:UInt32 = 0
        var blue:UInt32 = 0
        NSScanner(string: redString).scanHexInt(&red)
        NSScanner(string: greenString).scanHexInt(&green)
        NSScanner(string: blueString).scanHexInt(&blue)
        
        return UIColor( red: (CGFloat)(Float(red)/255.0),
                        green: (CGFloat)(Float(green)/255.0),
                        blue: (CGFloat)(Float(blue)/255.0),
                        alpha: (CGFloat)(alpha >= 0 ? alpha : 1))
        
    }
}