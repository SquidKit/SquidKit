//
//  TableItemCollection.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/12/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

@objc public protocol TableActions {
    func deselect(indexPath:NSIndexPath)
    func reload()
    func pushViewController(storyboardName:String, storyboardID:String)
    func presentViewController(storyboardName:String, storyboardID:String)
}

public class TableItem {
    
    public class Tag {
        let value:Int
        public init(value:Int) {
            self.value = value
        }
    }
    
    public var title:String?
    public var detailTitle:String?
    public var rowHeight:Float? {
        return nil
    }
    public var reuseIdentifier:String?
    public var tag:Tag?
    public var selectBlock:(item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> () = {(item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> () in}
    
    public var valueBlock:(item:TableItem) -> AnyObject? = {(item:TableItem) -> AnyObject? in
        return nil
    }
    
    public var setValueBlock:(item:TableItem, value:AnyObject?) -> () = {(item:TableItem, value:AnyObject?) -> () in}
    
    public convenience init(_ title:String, selectBlock:(item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> ()) {
        self.init(title, reuseIdentifier:nil, selectBlock:selectBlock)
    }
    
    public convenience init(_ title:String, reuseIdentifier:String?, selectBlock:(item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> ()) {
        self.init(title, reuseIdentifier:reuseIdentifier)
        self.selectBlock = selectBlock
    }
    
    public convenience init(_ title:String, reuseIdentifier:String?, valueBlock:(item:TableItem) -> AnyObject?) {
        self.init(title, reuseIdentifier:reuseIdentifier)
        self.valueBlock = valueBlock
    }
    
    public convenience init(_ title:String, reuseIdentifier:String?, valueBlock:(item:TableItem) -> AnyObject?, setValueBlock:(item:TableItem, value:AnyObject?) -> ()) {
        self.init(title, reuseIdentifier:reuseIdentifier, valueBlock:valueBlock)
        self.setValueBlock = setValueBlock
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
    
    public func value() -> AnyObject? {
        let blockValue:AnyObject? = self.valueBlock(item: self)
        return blockValue
    }
    
    public func setValue(value:AnyObject?) {
        self.setValueBlock(item: self, value: value)
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
    
    public subscript(tag:TableItem.Tag) -> TableItem? {
        for item in items {
            if let itemTag = item.tag where itemTag.value == tag.value {
                return item
            }
        }
        return nil
    }
}



