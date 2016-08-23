//
//  NavigatingTableItem.swift
//  SquidKit
//
//  Created by Mike Leavy on 9/7/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

/**
This is a TableItem that will navigate to the specified view controller
when selected.
*/
open class NavigatingTableItem: TableItem {
    
    
    open let navigationType:NavigatingTableItemNavigationType
    
    public init(_ title:String, reuseIdentifier:String?, navigationType:NavigatingTableItemNavigationType) {
        self.navigationType = navigationType
        super.init(title)
        self.reuseIdentifier = reuseIdentifier
        
        self.selectBlock = {[unowned self] (item:TableItem, indexPath:IndexPath, actionsTarget:TableActions?) -> () in
            
            if let tableAction = actionsTarget {
                switch self.navigationType {
                case .push(let storyboardName, let viewControllerID):
                    tableAction.pushViewController(storyboardName, storyboardID: viewControllerID)
                case .present(let storyboardName, let viewControllerID):
                    tableAction.presentViewController(storyboardName, storyboardID: viewControllerID)
                }
                tableAction.deselect(indexPath)
                tableAction.reload()
            }
        }
    }
    
    public convenience init(_ title: String, navigationType:NavigatingTableItemNavigationType) {
        self.init(title, reuseIdentifier:nil, navigationType:navigationType)
    }
}

public enum NavigatingTableItemNavigationType {
    case push(storyboardName:String, storyboardID:String)
    case present(storyboardName:String, storyboardID:String)
}

