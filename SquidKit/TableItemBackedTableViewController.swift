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
            var removeIndex:Int?
            var index = 0
            for aSection in sections {
                if aSection === section {
                    removeIndex = index
                    break
                }
                index++
            }
            if let indexToRemove = removeIndex {
                sections.removeAtIndex(indexToRemove)
            }
        }
        
        public subscript(indexPath:NSIndexPath) -> TableItem? {
            return self[indexPath.section, indexPath.row]
        }
        
        public subscript(section:Int, row:Int) -> TableItem? {
            if sections.count > section && sections[section].count > row {
                return sections[section][row]
            }
            Log.message("Unexpected: section or row is out of bounds")
            return nil
        }
        
        public subscript(section:Int) -> TableSection? {
            if sections.count > section {
                return sections[section]
            }
            Log.message("Unexpected: section is out of bounds")
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
            let viewController:UIViewController = UIStoryboard(name:storyboardName, bundle:nil).instantiateViewControllerWithIdentifier(storyboardID) as! UIViewController
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    public func presentViewController(storyboardName:String, storyboardID:String) {
        let viewController:UIViewController = UIStoryboard(name:storyboardName, bundle:nil).instantiateViewControllerWithIdentifier(storyboardID) as! UIViewController
        self.presentViewController(viewController, animated: true, completion: nil)
    }

}
