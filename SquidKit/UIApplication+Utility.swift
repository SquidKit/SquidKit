//
//  UIApplication+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 4/3/16.
//  Copyright © 2016 SquidKit. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    public func displayName() -> String {
        if let name:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String , name.characters.count > 0 {
            return name
        }
        
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }
    
}
