//
//  TableItemCollection.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/12/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public class TableItem {
    public var title:String?
    public var rowHeight:Float? {
        return nil
    }
    public var reuseIdentifier:String?
    public var selectBlock:(item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> () = {(item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> () in}
    
    public convenience init(_ title:String, selectBlock:(item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> ()) {
        self.init(title, reuseIdentifier:nil, selectBlock:selectBlock)
    }
    
    public convenience init(_ title:String, reuseIdentifier:String?, selectBlock:(item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> ()) {
        self.init(title, reuseIdentifier:reuseIdentifier)
        self.selectBlock = selectBlock
    }
    
    public init(_ title:String) {
        self.title = title
    }
    
    public convenience init(_ title:String, reuseIdentifier:String?) {
        self.init(title)
        self.reuseIdentifier = reuseIdentifier
    }
    
    public func titleForIndexPath(indexPath:NSIndexPath) -> String? {
        return nil
    }
}

extension TableItem: Printable, DebugPrintable {
    public var description: String {
        if let description = self.title {
            return description
        }
        return "TableItem <no name>"
    }

    public var debugDescription: String {
        return self.description
    }
}

public class TableSection {
    public var items = [TableItem]()
    public var title:String?
    
    public var count:Int {
        return items.count
    }
    
    public var height:Float? {
        return title == nil ? 0 : nil
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


