//
//  UIApplication+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 4/3/16.
//  Copyright © 2016-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

public extension UIApplication {
    
    public var isTestFlight: Bool {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {return false}
        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
    }
    
    public func displayName() -> String {
        if let name:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String , name.count > 0 {
            return name
        }
        
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }
}
