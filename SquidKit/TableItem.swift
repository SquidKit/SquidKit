//
//  TableItemCollection.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/12/14.
//  Copyright © 2014-2019 Squid Store, LLC. All rights reserved.
//

import Foundation

@objc public protocol TableActions {
    func deselect(_ indexPath:IndexPath)
    func reload()
    func pushViewController(_ storyboardName:String, storyboardID:String)
    func presentViewController(_ storyboardName:String, storyboardID:String)
}

open class TableItem {
    
    open class Tag {
        public let value:Int
        public init(value:Int) {
            self.value = value
        }
    }
    
    open var title:String?
    open var detailTitle:String?
    open var imageName:String?
    open var image:UIImage?
    
    open var rowHeight:Float? {
        return nil
    }
    open var reuseIdentifier:String?
    open var tag:Tag?
    open var selectBlock:(_ item:TableItem, _ indexPath:IndexPath, _ actionsTarget:TableActions?) -> () = {(item:TableItem, indexPath:IndexPath, actionsTarget:TableActions?) -> () in}
    
    open var valueBlock:(_ item:TableItem) -> AnyObject? = {(item:TableItem) -> AnyObject? in
        return nil
    }
    
    open var setValueBlock:(_ item:TableItem, _ value:AnyObject?) -> () = {(item:TableItem, value:AnyObject?) -> () in}
    
    open var enabledBlock:(_ item:TableItem) -> Bool = {(item:TableItem) -> Bool in
        return true
    }
    
    public convenience init(_ title:String, selectBlock:@escaping (_ item:TableItem, _ indexPath:IndexPath, _ actionsTarget:TableActions?) -> ()) {
        self.init(title, reuseIdentifier:nil, selectBlock:selectBlock)
    }
    
    public convenience init(_ title:String, reuseIdentifier:String?, selectBlock:@escaping (_ item:TableItem, _ indexPath:IndexPath, _ actionsTarget:TableActions?) -> ()) {
        self.init(title, reuseIdentifier:reuseIdentifier)
        self.selectBlock = selectBlock
    }
    
    public convenience init(_ title:String, reuseIdentifier:String?, valueBlock:@escaping (_ item:TableItem) -> AnyObject?) {
        self.init(title, reuseIdentifier:reuseIdentifier)
        self.valueBlock = valueBlock
    }
    
    public convenience init(_ title:String, reuseIdentifier:String?, valueBlock:@escaping (_ item:TableItem) -> AnyObject?, setValueBlock:@escaping (_ item:TableItem, _ value:AnyObject?) -> ()) {
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
    
    open func titleForIndexPath(_ indexPath:IndexPath) -> String? {
        return nil
    }
    
    open func value() -> AnyObject? {
        let blockValue:AnyObject? = self.valueBlock(self)
        return blockValue
    }
    
    open func setValue(_ value:AnyObject?) {
        self.setValueBlock(self, value)
    }
}

extension TableItem: CustomStringConvertible, CustomDebugStringConvertible {
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

open class TableSection {
    open var items = [TableItem]()
    open var title: String?
    open var footerTitle: String?
    
    open var count:Int {
        return items.count
    }
    
    open var height:Float? {
        return title == nil ? 0 : nil
    }
    
    public init() {
        
    }
    
    public init(_ title: String?) {
        self.title = title
    }
    
    open func append(_ item:TableItem) {
        self.items.append(item)
    }
    
    open subscript(index:Int) -> TableItem? {
        if (index < items.count) {
            return items[index]
        }
        
        return nil
    }
    
    open subscript(tag:TableItem.Tag) -> TableItem? {
        for item in items {
            if let itemTag = item.tag , itemTag.value == tag.value {
                return item
            }
        }
        return nil
    }
}



