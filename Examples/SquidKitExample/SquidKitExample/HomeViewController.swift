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
    
    var hostMapManager = HostMapManager(cacheStore: Preferences())

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let hostMapLoaded = hostMapManager.loadConfigurationMapFromResourceFile("HostMap.json")
        Log.message(hostMapLoaded ? "Loaded host map" : "Error loading host map")
        
        let tableItemExampleItem = NavigatingTableItem("Table Items Example", reuseIdentifier:"squidKitHomeCell", navigationType:.push(storyboardName:"Main", storyboardID:"tableItemsExampleVC"))
        
        let themeExampleItem = NavigatingTableItem("Theme Example", reuseIdentifier:"squidKitHomeCell", navigationType:.push(storyboardName:"Main", storyboardID:"themedVC"))
        
        let urlImageItem = NavigatingTableItem("URLImageView Example", reuseIdentifier:"squidKitHomeCell", navigationType:.push(storyboardName:"Main", storyboardID:"urlImageVC"))
        
        let hostConfigurationItem = TableItem("Host Configuration Example", reuseIdentifier: "squidKitHomeCell") { [weak self] (item, indexPath, actions) in
            let configurationViewController:HostConfigurationTableViewController = HostConfigurationTableViewController(style: .grouped)
            configurationViewController.hostMapManager = self?.hostMapManager
            configurationViewController.navigationItem.title = item.title
            self?.navigationController?.pushViewController(configurationViewController, animated: true)
        }
        
        let keyboardAccessoryItem = NavigatingTableItem("Keyboard Accessory", reuseIdentifier:"squidKitHomeCell", navigationType:.push(storyboardName:"Main", storyboardID:"keyboardAccessoryVC"))
        
        let appUpdateInfoItem = TableItem("Check for App Updates", reuseIdentifier: "squidKitHomeCell") { [weak self] (item, indexPath, actions) in
            UIApplication.shared.checkAppStoreVersion(completion: { [weak self] (version, url, error) in
                let alert = UIAlertController(title: "App Update", message: version.description, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                self?.present(alert, animated: true)
            })
            self?.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let styledStringItem = TableItem("Styled String Example", reuseIdentifier: "squidKitHomeCell") { [weak self] (item, indexPath, actions) in
            guard let styledViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "styledStringVC") as? StyledStringViewController else {return}
            styledViewController.navigationItem.title = item.title
            self?.navigationController?.pushViewController(styledViewController, animated: true)
        }
        
        // removed for Swift 4
        //let endpointExampleItem = NavigatingTableItem("Network Endpoint Example", reuseIdentifier:"squidKitHomeCell", navigationType:.Push(storyboardName:"Main", storyboardID:"endpointTestVC"))
        
        let jsonExampleItem = NavigatingTableItem("JSON Entity Example", reuseIdentifier:"squidKitHomeCell", navigationType:.push(storyboardName:"Main", storyboardID:"jsonEntityExampleVC"))
        
        //let remoteImageItem = NavigatingTableItem("Remote Image Example", reuseIdentifier:"squidKitHomeCell", navigationType:.Push(storyboardName:"Main", storyboardID:"remoteImageVC"))
        
        
        
        
        let section = TableSection()
        section.append(tableItemExampleItem)
        section.append(themeExampleItem)
        section.append(urlImageItem)
        section.append(hostConfigurationItem)
        section.append(keyboardAccessoryItem)
        section.append(appUpdateInfoItem)
        section.append(styledStringItem)
        //section.append(endpointExampleItem)
        section.append(jsonExampleItem)
        //section.append(remoteImageItem)
        
        self.model.append(section)
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.model[indexPath]!
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier!, for: indexPath) 
        cell.textLabel!.text = item.title
        return cell
    }
}

extension Preferences : HostMapCacheStorable {
    public func setEntry(_ entry:[String: AnyObject], key:String) {
        setPreference(entry, key: key)
    }
    
    public func getEntry(_ key:String) -> [String: AnyObject]? {
        return preference(key) as? [String: AnyObject]
    }
    
    public func remove(key:String) {
        remove(key)
    }
}


