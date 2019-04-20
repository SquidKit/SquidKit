//
//  UIDevice+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 5/12/15.
//  Copyright © 2017-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

public extension UIDevice {
    var isSimulator: Bool {
        var isSimulatorEnvironment = false
        
        #if targetEnvironment(simulator)
        isSimulatorEnvironment = true
        #endif
        
        return isSimulatorEnvironment
    }
}
