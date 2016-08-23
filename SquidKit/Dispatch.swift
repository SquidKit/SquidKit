//
//  Dispatch.swift
//  SquidKit
//
//  Created by Mike Leavy on 6/3/16.
//  Copyright © 2016 SquidKit. All rights reserved.
//

import Foundation

public func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

public func delay(_ delay:Double, queue:DispatchQueue, closure:@escaping ()->()) {
    queue.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
