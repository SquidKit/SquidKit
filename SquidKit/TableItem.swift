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
    public var selectBlock:(item:TableItem) -> () = {(item:TableItem) -> () in}
    
    public init(name:String, selectBlock:(item:TableItem) -> ()) {
        self.name = name
        self.selectBlock = selectBlock
    }
    
    public func description() -> NSString? {
        return name
    }
}

public typealias TableSection = [TableItem]