//
//  JSONEntityExampleViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 9/6/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit
import SquidKit

class JSONEntityItem: TableItem {
    let key:String
    let value:String
    
    init(key:String, value:String) {
        self.key = key
        self.value = value
        super.init("")
    }
    
}

class JSONEntityExampleViewController: TableItemBackedTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tableSection = TableSection()

        let json = JSONEntity(resourceFilename: "JSONEntityExample.json")
        let entities = json["entities_array"]
        for entity in entities {
            let float = entity["float_item"].float()
            tableSection.append(JSONEntityItem(key: "float_item", value:"\(float)"))
            
            let float2 = entity["float_item_as_string"].float()
            tableSection.append(JSONEntityItem(key: "float_item_as_string", value:"\(float2)"))
            
            let integer = entity["int_item"].int()
            tableSection.append(JSONEntityItem(key: "int_item", value:"\(integer)"))
            
            let integer2 = entity["int_item_as_float"].int()
            tableSection.append(JSONEntityItem(key: "int_item_as_float", value:"\(integer2)"))
            
            let integer3 = entity["int_item_as_string"].int()
            tableSection.append(JSONEntityItem(key: "int_item_as_string", value:"\(integer3)"))
            
            let boolean = entity["bool_item"].bool()
            tableSection.append(JSONEntityItem(key: "bool_item", value:"\(boolean)"))
            
            let boolean2 = entity["bool_item_as_int"].bool()
            tableSection.append(JSONEntityItem(key: "bool_item_as_int", value:"\(boolean2)"))
            
            let boolean3 = entity["bool_item_as_string"].bool()
            tableSection.append(JSONEntityItem(key: "bool_item_as_string", value:"\(boolean3)"))
            
            let string = entity["string_item"].string()
            tableSection.append(JSONEntityItem(key: "string_item", value:"\(string)"))
        }
        
        self.model.append(tableSection)

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("jsonEntityExampleCell", forIndexPath: indexPath) as UITableViewCell
        let item:JSONEntityItem = self.model[indexPath]! as JSONEntityItem
        cell.textLabel.text = item.key
        cell.detailTextLabel!.text = item.value
        return cell
    }

}
