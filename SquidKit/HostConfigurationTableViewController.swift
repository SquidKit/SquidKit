//
//  HostConfigurationTableViewController.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/28/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

public class ConfigurationItem : TableItem {
    public var protocolHostPair:ProtocolHostPair?
    public let key:String
    public let canonicalHost:String
    public let editable:Bool
    
    public required init(protocolHostPair:ProtocolHostPair?, key:String, canonicalHost:String, editable:Bool) {
        self.protocolHostPair = protocolHostPair
        self.key = key
        self.canonicalHost = canonicalHost
        self.editable = editable
        super.init(String.nonNilString(protocolHostPair?.host, stringForNil: ""))
        
        self.selectBlock = {[unowned self] (item:TableItem, indexPath:NSIndexPath, actionsTarget:TableActions?) -> () in
            HostMapManager.sharedInstance.setConfigurationForCanonicalHost(self.key, mappedHost:nil, canonicalHost: self.canonicalHost)
            if let aTable = actionsTarget {
                aTable.deselect(indexPath)
                aTable.reload()
            }
        }
    }
}


public class HostConfigurationTableViewController: TableItemBackedTableViewController, CustomHostCellDelegate {

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        for hostMap in HostMapManager.sharedInstance.hostMaps {
            let tableSection = TableSection(hostMap.canonicalHost)
            self.model.append(tableSection)
            for key in hostMap.sortedKeys {
                let pair = hostMap.pairWithKey(key as String)
                let configuration = ConfigurationItem(protocolHostPair:pair, key:key as String, canonicalHost:hostMap.canonicalHost, editable:hostMap.isEditable(key as String))
                tableSection.append(configuration)
            }
        }
        
        self.tableView.rowHeight = 44
        self.tableView.sectionHeaderHeight = 34

    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func isSelected(configItem:ConfigurationItem) -> Bool {
        if let runtimePair = EndpointMapper.mappedPairForCanonicalHost(configItem.canonicalHost) {
            if configItem.protocolHostPair != nil && runtimePair == configItem.protocolHostPair! && runtimePair.host != nil {
                return true
            }
        }
        return false
    }

    // MARK: - Table view data source


    let configItemReuseIdentifier:String = "com.squidkit.hostConfigurationDetailCellReuseIdentifier"
    let userItemReuseIdentifier:String = "com.squidkit.hostConfigurationDetailCellUserReuseIdentifier"
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if let configItem = self.model[indexPath]! as? ConfigurationItem {
        
            if !configItem.editable {
                cell = tableView.dequeueReusableCellWithIdentifier(configItemReuseIdentifier) as? UITableViewCell
                if cell == nil {
                    cell = UITableViewCell(style: .Subtitle, reuseIdentifier: configItemReuseIdentifier)
                }
                
                cell?.textLabel!.text = configItem.title
                cell?.detailTextLabel!.text = configItem.key
            }
            else {
                cell = CustomHostCell(style: .Default, reuseIdentifier: userItemReuseIdentifier)
                
                let customCell = cell as! CustomHostCell
                customCell.configItem = configItem
                customCell.delegate = self
            }
            
            cell?.accessoryType = self.isSelected(configItem) ? .Checkmark : .None
        }
        
        return cell!
    }
    
    // MARK: - Table CustomHostCellDelegate data source
    
    func hostTextDidChange(hostText:String?, configItem:ConfigurationItem) {
        HostMapManager.sharedInstance.setConfigurationForCanonicalHost(configItem.key, mappedHost:hostText, canonicalHost: configItem.canonicalHost)
        let pair = ProtocolHostPair(nil, hostText)
        configItem.protocolHostPair = pair
        self.tableView.reloadData()
    }
}

protocol CustomHostCellDelegate {
    func hostTextDidChange(hostText:String?, configItem:ConfigurationItem)
}

public class CustomHostCell: UITableViewCell, UITextFieldDelegate {
    var textField:UITextField?
    var configItem:ConfigurationItem?
    var delegate:CustomHostCellDelegate?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if textField == nil {
            textField = UITextField(frame:CGRectInset(self.contentView.bounds, 15, 5))
            self.contentView.addSubview(textField!)
            textField?.placeholder = "Enter custom host (e.g. \"api.host.com\")"
            textField?.font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleSubheadline), size: 13)
            textField?.keyboardType = .URL
            textField?.returnKeyType = .Done
            textField?.autocorrectionType = .No
            textField?.clearButtonMode = .WhileEditing
            textField?.delegate = self
            textField?.text = configItem!.protocolHostPair?.host
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        delegate?.hostTextDidChange(textField.text, configItem: configItem!)
    }
}

