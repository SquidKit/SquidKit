//
//  TableItemCollection.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/12/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public class TableItem: Describable {
    public var title:String?
    public var rowHeight:Float? {
        return nil
    }
    
    public var selectBlock:(item:TableItem, indexPath:NSIndexPath) -> () = {(item:TableItem, indexPath:NSIndexPath) -> () in}
    
    public convenience init(_ title:String, selectBlock:(item:TableItem, indexPath:NSIndexPath) -> ()) {
        self.init(title)
        self.selectBlock = selectBlock
    }
    
    public init(_ title:String) {
        self.title = title
    }
    
    public func titleForIndexPath(indexPath:NSIndexPath) -> String? {
        return nil
    }
    
    // MARK: - Describable protocol
    
    public func description() -> NSString? {
        return title
    }
    
    public func displayDescription() -> String {
        if let description = self.title {
            return description
        }
        return "TableItem <no name>"
    }
    
    public func debugDescription() -> String {
        return self.displayDescription()
    }
}

public class TableSection {
    public var items = [TableItem]()
    public var title:String?
    
    public var count:Int {
        return items.count
    }
    
    public var height:Float? {
        return nil
    }
    
    public init() {
        
    }
    
    public init(_ title:String) {
        self.title = title
    }
    
    public func append(item:TableItem) {
        self.items.append(item)
    }
    
    public subscript(index:Int) -> TableItem? {
        if (index < items.count) {
            return items[index]
        }
        
        return nil
    }

}