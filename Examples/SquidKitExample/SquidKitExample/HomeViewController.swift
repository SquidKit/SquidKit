//
//  HomeViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 9/6/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit
import SquidKit

class HomeViewController: TableItemBackedTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableItemExampleItem = TableItem("Table Items Example", selectBlock: { (item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> () in
            let tableItemsVC:UIViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("tableItemsExampleVC") as UIViewController
            self.navigationController!.pushViewController(tableItemsVC, animated: true)
        })
        
        let themeExampleItem = TableItem("Theme Example", selectBlock: { (item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> () in
            let themeVC:UIViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("themedVC") as UIViewController
            self.navigationController!.pushViewController(themeVC, animated: true)
        })
        
        let section = TableSection()
        section.append(tableItemExampleItem)
        section.append(themeExampleItem)
        self.model.append(section)
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("squidKitHomeCell", forIndexPath: indexPath) as UITableViewCell
        let item = self.model[indexPath]!
        cell.textLabel!.text = item.title
        return cell
    }
}
