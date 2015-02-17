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
        
        let tableItemExampleItem = NavigatingTableItem("Table Items Example", reuseIdentifier:"squidKitHomeCell", navigationType:.Push(storyboardName:"Main", storyboardID:"tableItemsExampleVC"))
        
        let themeExampleItem = NavigatingTableItem("Theme Example", reuseIdentifier:"squidKitHomeCell", navigationType:.Push(storyboardName:"Main", storyboardID:"themedVC"))
        
        let endpointExampleItem = NavigatingTableItem("Network Endpoint Example", reuseIdentifier:"squidKitHomeCell", navigationType:.Push(storyboardName:"Main", storyboardID:"endpointTestVC"))
        
        let jsonExampleItem = NavigatingTableItem("JSON Entity Example", reuseIdentifier:"squidKitHomeCell", navigationType:.Push(storyboardName:"Main", storyboardID:"jsonEntityExampleVC"))
        
        let remoteImageItem = NavigatingTableItem("Remote Image Example", reuseIdentifier:"squidKitHomeCell", navigationType:.Push(storyboardName:"Main", storyboardID:"remoteImageVC"))
        
        let urlImageItem = NavigatingTableItem("URLImageView Example", reuseIdentifier:"squidKitHomeCell", navigationType:.Push(storyboardName:"Main", storyboardID:"urlImageVC"))
        
        
        let section = TableSection()
        section.append(tableItemExampleItem)
        section.append(themeExampleItem)
        section.append(endpointExampleItem)
        section.append(jsonExampleItem)
        section.append(remoteImageItem)
        section.append(urlImageItem)
        self.model.append(section)
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = self.model[indexPath]!
        let cell = tableView.dequeueReusableCellWithIdentifier(item.reuseIdentifier!, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = item.title
        return cell
    }
}
