//
//  MasterViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 8/21/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit
import SquidKit

class MasterViewController: TableItemBackedTableViewController {


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigator:(item:TableItem) -> () = { (item:TableItem) -> () in
            SKLog.logMessage(item.title)
            let detailVC:DetailViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("detailVC") as DetailViewController
            detailVC.detailItem = item
            self.navigationController.pushViewController(detailVC, animated: true)
        }
        
        var section1 = TableSection(title:"One")
        var item1 = TableItem("One", navigator)
        section1.append(item1)
        self.appendSection(section1)
        
        var section2 = TableSection(title: "Two")
        var item2 = TableItem("Two", navigator)
        section2.append(item2)
        self.appendSection(section2)
        
        var section3 = TableSection()
        var item3 = TableItem("Three", navigator)
        section3.append(item3)
        self.appendSection(section3)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            if let item = self[indexPath] {
                (segue.destinationViewController as DetailViewController).detailItem = item
            }
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        if let item = self[indexPath] {
            cell.textLabel.text = item.title
        }
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }


}

