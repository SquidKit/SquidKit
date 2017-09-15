//
//  UIDevice+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 5/12/15.
//  Copyright (c) 2017 SquidKit. All rights reserved.
//

import UIKit

public extension UIDevice {
    public func simulator() -> Bool {
        var isSimulator = false
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
        isSimulator = true
        #endif
        
        return isSimulator
    }
}
