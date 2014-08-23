//
//  Describable.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/22/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

@objc public protocol Describable {
    func displayDescription() -> String
    func debugDescription() -> String
}