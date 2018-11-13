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
        
        let tableSection = TableSection()

        let json = JSONEntity(resourceFilename: "JSONEntityExample.json")
        let entities = json["entities_array"]
        for entity in entities {
            let double = entity["double_item"].double()
            tableSection.append(JSONEntityItem(key: "double_item", value:"\(String(describing: double))"))
            
            let double2 = entity["double_item_as_string"].double()
            tableSection.append(JSONEntityItem(key: "double_item_as_string", value:"\(String(describing: double2))"))
            
            let integer = entity["int_item"].int()
            tableSection.append(JSONEntityItem(key: "int_item", value:"\(String(describing: integer))"))
            
            let integer2 = entity["int_item_as_float"].int()
            tableSection.append(JSONEntityItem(key: "int_item_as_float", value:"\(String(describing: integer2))"))
            
            let integer3 = entity["int_item_as_string"].int()
            tableSection.append(JSONEntityItem(key: "int_item_as_string", value:"\(String(describing: integer3))"))
            
            let boolean = entity["bool_item"].bool()
            tableSection.append(JSONEntityItem(key: "bool_item", value:"\(String(describing: boolean))"))
            
            let boolean2 = entity["bool_item_as_int"].bool()
            tableSection.append(JSONEntityItem(key: "bool_item_as_int", value:"\(String(describing: boolean2))"))
            
            let boolean3 = entity["bool_item_as_string"].bool()
            tableSection.append(JSONEntityItem(key: "bool_item_as_string", value:"\(String(describing: boolean3))"))
            
            let string = entity["string_item"].string()
            tableSection.append(JSONEntityItem(key: "string_item", value:"\(String(describing: string))"))
            
            let dictionaryItem = entity["dictionary_item"]["name"].string()
            tableSection.append(JSONEntityItem(key: "dictionary_item", value:"\(String(describing: dictionaryItem))"))
            
            let arrayItem = entity["array_item"]
            for arrayObj in arrayItem {
                let arrayObjEntity = arrayObj["item"].string()
                tableSection.append(JSONEntityItem(key: "array_item", value:"\(String(describing: arrayObjEntity))"))
            }
        }
        
        self.model.append(tableSection)

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jsonEntityExampleCell", for: indexPath) 
        let item:JSONEntityItem = self.model[indexPath]! as! JSONEntityItem
        cell.textLabel!.text = item.key
        cell.detailTextLabel!.text = item.value
        return cell
    }

}
