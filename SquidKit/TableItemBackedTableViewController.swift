//
//  TableItemBackedTableViewController.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/21/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

public class TableItemBackedTableViewController: UITableViewController {

    public var sections = [TableSection]()
    
    public func appendSection() {
        let section = TableSection()
        self.sections.append(section)
    }
    
    public func appendItem(item:TableItem, section:Int) {
        sections[section].append(item)
    }
    
    public subscript(indexPath:NSIndexPath) -> TableItem? {
        return self[indexPath.section, indexPath.row]
    }
    
    public subscript(section:Int, row:Int) -> TableItem? {
        if sections.count > section && sections[section].count > row {
            return sections[section][row]
        }
        SKLog.logMessage("Unexpected: section or row is out of bounds")
        return nil
    }
    
    // MARK: - Table View
    
    public override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return sections.count
    }
    
    public override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    public override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if let item = self[indexPath] {
            item.selectBlock(item:item)
        }
    }
    
}
