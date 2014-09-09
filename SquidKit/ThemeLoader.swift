//
//  ThemeLoader.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//
//  Acknowledgments to Brent Simmons and the DB5 theme model (https://github.com/quartermaster/DB5),
//  after which this SquidKit themes are modeled. SquidKit eschews Plists in favor of a more portable
//  JSON text file to define a theme; and there are fewer “themeable” elements in SquidKit.

import Foundation

public class ThemeLoader {
    
    public class func loadThemesFromResourceFile(fileName:String) -> Bool {
        var result = false
        
        let json = JSONEntity(resourceFilename: fileName)
        let themes = json["themes"]
        if themes.isValid && themes.count > 0 {
            
            result = true
            
            var loadedThemes = [String: Theme]()
            
            for aTheme in themes {
                var theme:Theme = Theme()
                theme.name = aTheme["name"].string()
                
                let attributes = aTheme["attributes"]
                let themeDictionary = NSMutableDictionary(capacity: attributes.count)
                for attribute in attributes {
                    let anyAttribute:AnyObject? = ThemeLoader.attributeFromAttributeDictionary(attribute.dictionary(NSDictionary())!)
                    if anyAttribute != nil {
                        if let attributeKey = attribute["key"].string() {
                            themeDictionary.setObject(anyAttribute, forKeyedSubscript: attributeKey)
                        }
                        else if let attributeKeys:NSArray = attribute["keys"].array() {
                            for keyValue:AnyObject in attributeKeys {
                                themeDictionary.setObject(anyAttribute, forKeyedSubscript: keyValue as String)
                            }
                        }
                        else {
                            themeDictionary.addEntriesFromDictionary(attribute.dictionary(NSDictionary())!)
                        }
                    }
                }
                
                if theme.name != nil && themeDictionary.count > 0 {
                    var swDictionary = [String: AnyObject]()
                    
                    themeDictionary.enumerateKeysAndObjectsUsingBlock({ (key:AnyObject!, value:AnyObject!, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                        swDictionary[key as String] = value!
                    })
                    
                    theme.dictionary = swDictionary
                    loadedThemes[theme.name!] = theme
                }
            }
            
            if loadedThemes.count > 0 {
                ThemeManager.sharedInstance.themes = loadedThemes
            }
        }
            
        
        return result
    }
    
    class func attributeFromAttributeDictionary(attributeDictionary:NSDictionary) -> AnyObject? {
        
        var attribute:AnyObject?
        
        if let attributeType = attributeDictionary.objectForKey("type") as? String {
            if attributeType == "color" {
                attribute = ThemeLoader.colorFromAttributeDictionary(attributeDictionary)
            }
        }
        else {
            attribute = attributeDictionary.objectForKey("value")
        }
        
        return attribute
    }
    
    class func colorFromAttributeDictionary(attributeDictionary:NSDictionary) -> UIColor? {
        var color:UIColor?
        
        if let value:String = attributeDictionary.objectForKey("value") as? String {
            let alpha:NSNumber? = attributeDictionary.objectForKey("alpha") as? NSNumber
            color = UIColor.colorWithHexString(value, alpha: alpha != nil ? Float(alpha!.floatValue) : 1)
        }
        
        return color
        
    }
}