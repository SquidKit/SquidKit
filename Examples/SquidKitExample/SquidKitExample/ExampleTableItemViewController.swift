//
//  ExampleTableItemViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 8/21/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit
import SquidKit

class TallTableItem : TableItem, Describable {
    override var rowHeight:Float? {
        return 88
    }
}

class RepeatingTableItem : TableItem, Describable {
    override func titleForIndexPath(indexPath:NSIndexPath) -> String? {
        return "Section \(indexPath.section+1), Row \(indexPath.row+1)"
    }
}

class ExampleTableItemViewController: TableItemBackedTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKLog.setLogStatus(.Simulator)
                
        // TableSections and TableItems are the model for our table view. Below, we create 3 sections, each with a single item.
        
        // navigator is the callback that we will use for the first 3 TableItems.
        let navigator:(item:TableItem, indexPath:NSIndexPath) -> () = { (item:TableItem, indexPath:NSIndexPath) -> () in
            SKLog.logMessage(item.title)
            let detailVC:DetailViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("detailVC") as DetailViewController
            detailVC.detailItem = item
            self.navigationController.pushViewController(detailVC, animated: true)
        }
        
        var section1 = TableSection("One")
        var item1 = TableItem("One", selectBlock:navigator)
        section1.append(item1)
        self.appendSection(section1)
        
        var section2 = TableSection("Two")
        // here we create an instance of our subclassed TableItem - TallTableItem
        var item2 = TallTableItem("Tall Two", selectBlock:navigator)
        section2.append(item2)
        self.appendSection(section2)
        
        var section3 = TableSection()
        var item3 = TableItem("Theme Example", selectBlock: { (item:TableItem, indexPath:NSIndexPath) -> () in
            let detailVC:ThemedViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("themedVC") as ThemedViewController
            self.navigationController.pushViewController(detailVC, animated: true)
            })
            
        section3.append(item3)
        self.appendSection(section3)
        
        
        // We can even add the same TableItem multiple times to a section; in this case, we do this with a subclass
        // of TableItem named RepeatingTableItem (defined above). RepeatingTableItem returns a title denoting
        // its position in the table.
        var repeatingItemSection = TableSection("Repeating items")
        var item4 = RepeatingTableItem("Repeating", selectBlock:navigator)
        repeatingItemSection.append(item4)
        repeatingItemSection.append(item4)
        repeatingItemSection.append(item4)
        repeatingItemSection.append(item4)
        self.appendSection(repeatingItemSection)
        
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
            if let title = item.titleForIndexPath(indexPath) {
                cell.textLabel.text = title
            }
            else {
                cell.textLabel.text = item.title
            }
        }
        return cell
    }

}

