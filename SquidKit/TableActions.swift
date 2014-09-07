//
//  TableActions.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/29/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

@objc public protocol TableActions {
    func deselect(indexPath:NSIndexPath)
    func reload()
    func pushViewController(storyboardName:String, storyboardID:String)
    func presentViewController(storyboardName:String, storyboardID:String)
}