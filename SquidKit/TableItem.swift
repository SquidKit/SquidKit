//
//  TableItemCollection.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/12/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public class TableItem {
    public var name:String?
    public var closure:() -> ()?
    
    public init(name:String, closure:() -> ()) {
        self.name = name
        self.closure = closure
    }
}
