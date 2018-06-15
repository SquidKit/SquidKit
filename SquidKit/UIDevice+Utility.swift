//
//  UIDevice+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 5/12/15.
//  Copyright (c) 2017 SquidKit. All rights reserved.
//

import UIKit

public extension UIDevice {
    public var isSimulator: Bool {
        var isSimulatorEnvironment = false
        
        #if targetEnvironment(simulator)
        isSimulatorEnvironment = true
        #endif
        
        return isSimulatorEnvironment
    }
}
