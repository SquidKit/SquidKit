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
    
    public class func colorWithHex(_ hex:UInt32, alpha:Float = 1) -> UIColor {
        return UIColor(red:((CGFloat)((hex & 0xFF0000) >> 16))/255.0,
            green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0,
            blue: ((CGFloat)(hex & 0xFF))/255.0,
            alpha: (CGFloat)(alpha))
    }
    
    public class func colorWithHexString(_ hexString:String?, alpha:Float = 1) -> UIColor? {
        
        if let hex = hexString {
            let s:NSMutableString = NSMutableString(string:hex)
            s.replaceOccurrences(of: "#", with: "", options:.literal, range: NSRange(location: 0, length: s.length))
            s.replaceOccurrences(of: "0x", with: "", options:.caseInsensitive, range: NSRange(location: 0, length: s.length))
            CFStringTrimWhitespace(s as CFMutableString);
            

            // allow strings > 6 character, additional characters assumed to be comment or descriptor

            if s.length < 6 {
                return nil
            }
                    
            let redString = s.substring(to: 2)
            let greenString = s.substring(with: NSRange(location: 2, length: 2))
            let blueString = s.substring(with: NSRange(location: 4, length: 2))
            
            var red:UInt32 = 0
            var green:UInt32 = 0
            var blue:UInt32 = 0
            Scanner(string: redString).scanHexInt32(&red)
            Scanner(string: greenString).scanHexInt32(&green)
            Scanner(string: blueString).scanHexInt32(&blue)
            
            return UIColor( red: (CGFloat)(Float(red)/255.0),
                            green: (CGFloat)(Float(green)/255.0),
                            blue: (CGFloat)(Float(blue)/255.0),
                            alpha: (CGFloat)(alpha))
            
        }
        
        return nil
    }
}
