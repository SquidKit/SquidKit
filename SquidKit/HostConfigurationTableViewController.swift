//
//  HostConfigurationTableViewController.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/28/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

open class ConfigurationItem : TableItem {
    open var protocolHostPair:ProtocolHostPair?
    public let key:String
    public let canonicalHost:String
    public let editable:Bool
    let hostMapManager:HostMapManager!
    
    public required init(hostMapManager:HostMapManager, protocolHostPair:ProtocolHostPair?, key:String, canonicalHost:String, editable:Bool) {
        self.hostMapManager = hostMapManager
        self.protocolHostPair = protocolHostPair
        self.key = key
        self.canonicalHost = canonicalHost
        self.editable = editable
        super.init(String.nonNilString(protocolHostPair?.host, stringForNil: ""))
        
        self.selectBlock = {[unowned self] (item:TableItem, indexPath:IndexPath, actionsTarget:TableActions?) -> () in
            self.hostMapManager.setConfigurationForCanonicalHost(self.key, mappedHost:nil, canonicalHost: self.canonicalHost)
            if let aTable = actionsTarget {
                aTable.deselect(indexPath)
                aTable.reload()
            }
        }
    }
}


open class HostConfigurationTableViewController: TableItemBackedTableViewController, CustomHostCellDelegate {
    
    open var hostMapManager:HostMapManager?

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let manager = hostMapManager {
            for hostMap in manager.hostMaps {
                let tableSection = TableSection(hostMap.canonicalHost)
                self.model.append(tableSection)
                for key in hostMap.sortedKeys {
                    let pair = hostMap.pairWithKey(key as String)
                    let configuration = ConfigurationItem(hostMapManager:manager, protocolHostPair:pair, key:key as String, canonicalHost:hostMap.canonicalHost, editable:hostMap.isEditable(key as String))
                    tableSection.append(configuration)
                }
            }
        }
        
        self.tableView.rowHeight = 44
        self.tableView.sectionHeaderHeight = 34

    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func isSelected(_ configItem:ConfigurationItem) -> Bool {
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
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if let configItem = self.model[indexPath]! as? ConfigurationItem {
        
            if !configItem.editable {
                cell = tableView.dequeueReusableCell(withIdentifier: configItemReuseIdentifier)
                if cell == nil {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: configItemReuseIdentifier)
                }
                
                cell?.textLabel!.text = configItem.title
                cell?.detailTextLabel!.text = configItem.key
            }
            else {
                cell = CustomHostCell(style: .default, reuseIdentifier: userItemReuseIdentifier)
                
                let customCell = cell as! CustomHostCell
                customCell.configItem = configItem
                customCell.delegate = self
            }
            
            cell?.accessoryType = self.isSelected(configItem) ? .checkmark : .none
        }
        
        return cell!
    }
    
    // MARK: - Table CustomHostCellDelegate data source
    
    func hostTextDidChange(_ hostText:String?, configItem:ConfigurationItem) {
        hostMapManager?.setConfigurationForCanonicalHost(configItem.key, mappedHost:hostText, canonicalHost: configItem.canonicalHost)
        let pair = ProtocolHostPair(nil, hostText)
        configItem.protocolHostPair = pair
        self.tableView.reloadData()
    }
}

protocol CustomHostCellDelegate {
    func hostTextDidChange(_ hostText:String?, configItem:ConfigurationItem)
}

open class CustomHostCell: UITableViewCell, UITextFieldDelegate {
    var textField:UITextField?
    var configItem:ConfigurationItem?
    var delegate:CustomHostCellDelegate?
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if textField == nil {
            textField = UITextField(frame:self.contentView.bounds.insetBy(dx: 15, dy: 5))
            self.contentView.addSubview(textField!)
            textField?.placeholder = "Enter custom host (e.g. \"api.host.com\")"
            textField?.font = UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline), size: 13)
            textField?.keyboardType = .URL
            textField?.returnKeyType = .done
            textField?.autocorrectionType = .no
            textField?.clearButtonMode = .whileEditing
            textField?.delegate = self
            textField?.text = configItem!.protocolHostPair?.host
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.hostTextDidChange(textField.text, configItem: configItem!)
    }
}

