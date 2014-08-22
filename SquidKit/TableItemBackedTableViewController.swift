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
    
    public func itemAt(indexPath:NSIndexPath) -> TableItem {
        return sections[indexPath.section][indexPath.row]
    }
    
    // MARK: - Table View
    
    public override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return sections.count
    }
    
    public override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    public override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let item = self.itemAt(indexPath)
        item.closure(item:item)
    }
    
}
