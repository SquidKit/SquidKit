//
//  TableItemBackedTableViewController.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/21/14.
//  Copyright © 2014-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

open class TableItemBackedTableViewController: UITableViewController {

    open var model = Model()
    
    
    // MARK: - Table View
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = model[indexPath]?.rowHeight {
            return CGFloat(height)
        }
        return tableView.rowHeight
    }
    
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let height = model[section]?.height {
            return CGFloat(height)
        }
        return UITableView.automaticDimension
    }
    
    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model[section]!.count
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = model[indexPath] {
            item.selectBlock(item, indexPath, self)
        }
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model[section]!.title
    }
    
    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return model[section]?.footerTitle
    }
    
    // MARK: - Model
    
    open class Model {
        fileprivate var sections = [TableSection]()
        
        fileprivate init() {
            
        }
        
        open func append(_ section:TableSection) {
            sections.append(section)
        }
        
        open func insert(_ section:TableSection, atIndex:Int) {
            sections.insert(section, at: atIndex)
        }
        
        open func remove(_ section:TableSection) {
            if let index = sections.firstIndex (where: {$0 === section}) {
                sections.remove(at: index)
            }
        }
        
        open func reset() {
            sections = [TableSection]()
        }
        
        open func indexForSection(_ section:TableSection) -> Int? {
            return sections.firstIndex{$0 === section}
        }
        
        open func indexPathForItem(_ item:TableItem) -> IndexPath? {
            for (count, element) in sections.enumerated() {
                if let itemIndex = element.items.firstIndex(where: {$0 === item}) {
                    return IndexPath(row: itemIndex, section: count)
                }
            }
            
            return nil
        }
        
        open subscript(indexPath:IndexPath) -> TableItem? {
            return self[(indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row]
        }
        
        open subscript(section:Int, row:Int) -> TableItem? {
            if sections.count > section && sections[section].count > row {
                return sections[section][row]
            }
            return nil
        }
        
        open subscript(tag:TableItem.Tag) -> TableItem? {
            for section in sections {
                if let item:TableItem = section[tag] {
                    return item
                }
            }
            return nil
        }
        
        open subscript(section:Int) -> TableSection? {
            if sections.count > section {
                return sections[section]
            }
            return nil
        }
    }
}

// MARK: - TableActions

extension TableItemBackedTableViewController: TableItemAction {
    
    public var viewController: UIViewController {
        return self
    }

    public func deselect(_ indexPath:IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    public func reload() {
        self.tableView.reloadData()
    }
    
    public func pushViewController(_ storyboardName:String, storyboardID:String) {
        if let navigationController = self.navigationController {
            let viewController:UIViewController = UIStoryboard(name:storyboardName, bundle:nil).instantiateViewController(withIdentifier: storyboardID) 
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    public func presentViewController(_ storyboardName:String, storyboardID:String) {
        let viewController:UIViewController = UIStoryboard(name:storyboardName, bundle:nil).instantiateViewController(withIdentifier: storyboardID) 
        self.present(viewController, animated: true, completion: nil)
    }

}
