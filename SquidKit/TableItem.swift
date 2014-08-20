//
//  TableItemCollection.swift
//  Vunder
//
//  Created by Mike Leavy on 8/12/14.
//  Copyright (c) 2014 SquidStore. All rights reserved.
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
