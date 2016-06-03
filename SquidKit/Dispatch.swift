//
//  Dispatch.swift
//  SquidKit
//
//  Created by Mike Leavy on 6/3/16.
//  Copyright © 2016 SquidKit. All rights reserved.
//

import Foundation

public func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

public func delay(delay:Double, queue:dispatch_queue_t, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        queue, closure)
}
