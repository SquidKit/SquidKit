//
//  ExampleTableItemViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 8/21/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit
import SquidKit

class TallTableItem : TableItem {
    override var rowHeight:Float? {
        return 88
    }
}

class RepeatingTableItem : TableItem {
    override func titleForIndexPath(indexPath:NSIndexPath) -> String? {
        return "Section \(indexPath.section+1), Row \(indexPath.row+1)"
    }
}

class ExampleTableItemViewController: TableItemBackedTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.setLogStatus(.Simulator)
                
        // TableSections and TableItems are the model for our table view. Below, we create 3 sections, each with a single item.
        
        // navigator is the callback that we will use for the first 3 TableItems.
        let navigator:(item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> () = { (item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> () in
            Log.message(item.title)
            let detailVC:DetailViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("detailVC") as! DetailViewController
            detailVC.detailItem = item
            self.navigationController!.pushViewController(detailVC, animated: true)
        }
        
        var section1 = TableSection("One")
        var item1 = TableItem("One", selectBlock:navigator)
        section1.append(item1)
        self.model.append(section1)
        
        var section2 = TableSection("Two")
        // here we create an instance of our subclassed TableItem - TallTableItem
        var item2 = TallTableItem("Tall Two", selectBlock:navigator)
        section2.append(item2)
        self.model.append(section2)
        
        
        
        // We can even add the same TableItem multiple times to a section; in this case, we do this with a subclass
        // of TableItem named RepeatingTableItem (defined above). RepeatingTableItem returns a title denoting
        // its position in the table.
        var repeatingItemSection = TableSection("Repeating items")
        var item4 = RepeatingTableItem("Repeating", selectBlock:navigator)
        repeatingItemSection.append(item4)
        repeatingItemSection.append(item4)
        repeatingItemSection.append(item4)
        repeatingItemSection.append(item4)
        self.model.append(repeatingItemSection)
        
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            if let item = self.model[indexPath!] {
                (segue.destinationViewController as! DetailViewController).detailItem = item
            }
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        if let item = self.model[indexPath] {
            if let title = item.titleForIndexPath(indexPath) {
                cell.textLabel!.text = title
            }
            else {
                cell.textLabel!.text = item.title
            }
        }
        return cell
    }

}

