//
//  ThemeLoader.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright © 2014-2019 Squid Store, LLC. All rights reserved.
//
//  Acknowledgments to Brent Simmons and the DB5 theme model (https://github.com/quartermaster/DB5),
//  after which this SquidKit themes are modeled. SquidKit eschews Plists in favor of a more portable
//  JSON text file to define a theme; and there are fewer “themeable” elements in SquidKit.

import UIKit

open class ThemeLoader {
    
    open class func loadThemesFromResourceFile(_ fileName:String) -> Bool {
        var result = false
        
        let json = JSONEntity(resourceFilename: fileName)
        let themes = json["themes"]
        if themes.isValid && themes.count > 0 {
            
            result = true
            
            var loadedThemes = [String: Theme]()
            
            for aTheme in themes {
                let theme:Theme = Theme()
                theme.name = aTheme["name"].stringWithDefault("unnamed theme")
                
                let attributes = aTheme["attributes"]
                let themeDictionary = NSMutableDictionary(capacity: attributes.count)
                for attribute in attributes {
                    let (key, value) = ThemeLoader.attributeFromAttributeEntity(attribute)
                    if value != nil {
                        themeDictionary.setObject(value!, forKey: key as NSString)
                    }
                }
                
                if theme.name != nil && themeDictionary.count > 0 {
                    var swDictionary = [String: AnyObject]()
                    
                    themeDictionary.enumerateKeysAndObjects({ (key:Any!, value:Any!, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                        swDictionary[key as! String] = value as AnyObject
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
    
    class func attributeFromAttributeEntity(_ entity:JSONEntity) -> (String, AnyObject?) {
        
        if let dictionary = entity.dictionary() {
            if let _ = dictionary.object(forKey: "color") as? String {
                return (entity.key, ThemeLoader.colorFromAttributeDictionary(dictionary))
            }
        }
        
        return (entity.key, entity.realValue)
    }
    
    class func colorFromAttributeDictionary(_ attributeDictionary:NSDictionary) -> UIColor? {
        var color:UIColor?
        
        if let hexColor:String = attributeDictionary.object(forKey: "color") as? String {
            let alpha:NSNumber? = attributeDictionary.object(forKey: "alpha") as? NSNumber
            color = UIColor.colorWithHexString(hexColor, alpha: alpha != nil ? Float(alpha!.floatValue) : 1)
        }
        
        return color
        
    }
}
