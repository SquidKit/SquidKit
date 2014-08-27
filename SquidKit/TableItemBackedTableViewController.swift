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
    
    public func appendSection(section:TableSection) {
        self.sections.append(section)
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
    
    // MARK: - Table View
    
    public override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if let height = self[indexPath]?.rowHeight? {
            return CGFloat(height)
        }
        return tableView.rowHeight
    }
    
    public override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = self[section]?.height? {
            return CGFloat(height)
        }
        return tableView.sectionHeaderHeight
    }
    
    public override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return sections.count
    }
    
    public override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    public override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if let item = self[indexPath] {
            item.selectBlock(item:item, indexPath:indexPath)
        }
    }
    
    public override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        return sections[section].title
    }
    
}
