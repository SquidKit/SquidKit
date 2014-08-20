//
//  UIColorExtension.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation
import UIKit

public class UIColorExtension {
    
    public class func colorWithHex(hex:UInt32, alpha:Float = -1) -> UIColor {
        return UIColor.colorWithHex(hex, alpha: alpha)
    }
    
    public class func colorWithHexString(hexString:String, alpha:Float = -1) -> UIColor {
        return UIColor.colorWithHexString(hexString, alpha: alpha)
    }
}