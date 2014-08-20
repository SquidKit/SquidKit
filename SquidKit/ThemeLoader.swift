//
//  ThemeLoader.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright (c) 2014 SquidStore. All rights reserved.
//

import Foundation

public class ThemeLoader {
    
    public class func loadThemesFromResourceFile(fileName:String) -> Bool {
        var result = false
        
        if let themesDictionary = NSDictionary.dictionaryFromResourceFile(fileName) {
            result = true
            
            if let themes:NSArray = themesDictionary.objectForKey("themes") as? NSArray {
                
                var loadedThemes = [String: Theme]()
                
                for themeObject in themes {
                    let themeDict:NSDictionary = themeObject as NSDictionary
                    var theme:Theme = Theme()
                    theme.name = themeDict.objectForKey("name") as? String
                    
                    if let attributes:NSArray = themeDict.objectForKey("attributes") as? NSArray {
                        let themeDictionary:NSMutableDictionary = NSMutableDictionary(capacity: attributes.count)
                        
                        for attributeObject in attributes {
                            let attribute = attributeObject as NSDictionary
                            let anyAttribute:AnyObject? = ThemeLoader.attributeFromAttributeDictionary(attribute)
                            
                            if anyAttribute != nil {
                                if let attributeKey:String = attribute.objectForKey("key") as? String {
                                    themeDictionary.setObject(anyAttribute, forKeyedSubscript: attributeKey)
                                }
                                else if let attributeKeys:NSArray = attribute.objectForKey("keys") as? NSArray {
                                    for keyValue:AnyObject in attributeKeys {
                                        themeDictionary.setObject(anyAttribute, forKeyedSubscript: keyValue as String)
                                    }
                                }
                                else {
                                    themeDictionary.addEntriesFromDictionary(attribute)
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
                }
                
                if loadedThemes.count > 0 {
                    ThemeManager.sharedInstance.themes = loadedThemes
                }
                
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
            else {
                attribute = attributeDictionary.objectForKey("value")
            }
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