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
        
        self.appendSection()
        
        var item = TableItem(name: "One", { (item:TableItem) -> () in
            SKLog.logMessage(item.name)
            let detailVC:DetailViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("detailVC") as DetailViewController
            detailVC.detailItem = item
            self.navigationController.pushViewController(detailVC, animated: true)
        })
        
        self.appendItem(item, section:0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let item = self.itemAt(indexPath)
            (segue.destinationViewController as DetailViewController).detailItem = item
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let item = self.itemAt(indexPath)
        cell.textLabel.text = item.name
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }


}

