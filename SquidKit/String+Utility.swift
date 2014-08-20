//
//  String+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/17/14.
//  Copyright (c) 2014 SquidStore. All rights reserved.
//

import Foundation

public extension String {
    
    public static func nonNilString(string:String?, stringForNil:String = "") -> String {
        if let nonNilString = string {
            return nonNilString
        }
        
        return stringForNil
    }
}