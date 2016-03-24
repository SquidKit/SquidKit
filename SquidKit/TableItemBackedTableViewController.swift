//
//  TableItemBackedTableViewController.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/21/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

public class TableItemBackedTableViewController: UITableViewController {

    public var model = Model()
    
    
    // MARK: - Table View
    
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = self.model[indexPath]?.rowHeight {
            return CGFloat(height)
        }
        return tableView.rowHeight
    }
    
    public override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = self.model[section]?.height {
            return CGFloat(height)
        }
        return tableView.sectionHeaderHeight
    }
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.model.sections.count
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model[section]!.count
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let item = self.model[indexPath] {
            item.selectBlock(item:item, indexPath:indexPath, actionsTarget:self)
        }
    }
    
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.model[section]!.title
    }
    
    // MARK: - Model
    
    public class Model {
        private var sections = [TableSection]()
        
        private init() {
            
        }
        
        public func append(section:TableSection) {
            sections.append(section)
        }
        
        public func insert(section:TableSection, atIndex:Int) {
            sections.insert(section, atIndex: atIndex)
        }
        
        public func remove(section:TableSection) {
            if let index = sections.indexOf ({$0 === section}) {
                sections.removeAtIndex(index)
            }
        }
        
        public func reset() {
            sections = [TableSection]()
        }
        
        public func indexForSection(section:TableSection) -> Int? {
            return sections.indexOf{$0 === section}
        }
        
        public func indexPathForItem(item:TableItem) -> NSIndexPath? {
            for (count, element) in sections.enumerate() {
                if let itemIndex = element.items.indexOf({$0 === item}) {
                    return NSIndexPath(forRow: itemIndex, inSection: count)
                }
            }
            
            return nil
        }
        
        public subscript(indexPath:NSIndexPath) -> TableItem? {
            return self[indexPath.section, indexPath.row]
        }
        
        public subscript(section:Int, row:Int) -> TableItem? {
            if sections.count > section && sections[section].count > row {
                return sections[section][row]
            }
            return nil
        }
        
        public subscript(tag:TableItem.Tag) -> TableItem? {
            for section in sections {
                if let item:TableItem = section[tag] {
                    return item
                }
            }
            return nil
        }
        
        public subscript(section:Int) -> TableSection? {
            if sections.count > section {
                return sections[section]
            }
            return nil
        }
    }
}

// MARK: - TableActions

extension TableItemBackedTableViewController: TableActions {

    public func deselect(indexPath:NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    public func reload() {
        self.tableView.reloadData()
    }
    
    public func pushViewController(storyboardName:String, storyboardID:String) {
        if let navigationController = self.navigationController {
            let viewController:UIViewController = UIStoryboard(name:storyboardName, bundle:nil).instantiateViewControllerWithIdentifier(storyboardID) 
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    public func presentViewController(storyboardName:String, storyboardID:String) {
        let viewController:UIViewController = UIStoryboard(name:storyboardName, bundle:nil).instantiateViewControllerWithIdentifier(storyboardID) 
        self.presentViewController(viewController, animated: true, completion: nil)
    }

}
