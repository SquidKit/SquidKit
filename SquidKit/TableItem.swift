//
//  TableItemCollection.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/12/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public class TableItem: NSObject {
    public var name:String?
    public var closure:(item:TableItem) -> ()?
    
    public init(name:String, closure:(item:TableItem) -> ()) {
        self.name = name
        self.closure = closure
    }
    
    public func description() -> NSString? {
        return name
    }
}

public typealias TableSection = [TableItem]