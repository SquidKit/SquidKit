//
//  Theme.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/15/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//
//  Acknowledgments to Brent Simmons and the DB5 theme model (https://github.com/quartermaster/DB5),
//  after which this SquidKit themes are modeled. SquidKit eschews Plists in favor of a more portable
//  JSON text file to define a theme; and there are fewer “themeable” elements in SquidKit.

import Foundation
import UIKit

private let _ThemeManagerSharedInstance = ThemeManager()

public class ThemeManager {
    
    var themes = [String: Theme]()
    
    var activeTheme:Theme? {
        didSet {
            SKLog.logMessage("Active theme is now: \(activeTheme?.name)")
        }
    }
    
    public class var sharedInstance: ThemeManager {
        return _ThemeManagerSharedInstance
    }
    
    public init() {
        
    }
    
    public func setActiveThemeByName(name:String) {
        
        if let foundTheme = themes[name] {
            self.activeTheme = foundTheme
        }
        else {
            self.setDefaultTheme()
        }
    }
    
    public func setDefaultTheme() {
        if themes.count > 0 {
            var arrayOfKeys:[String] = Array(themes.keys)
            arrayOfKeys = sorted(arrayOfKeys) {$0 < $1}
            self.activeTheme = themes[arrayOfKeys[0]]
        }
    }
    
    public func updateThemedSubviewsOfView(view:UIView, recursive:Bool = true) {
        for aView in view.subviews {
            aView.setNeedsDisplay()
            if (recursive) {
                self.updateThemedSubviewsOfView(aView as UIView, recursive: true)
            }
        }
    }

}

public class Theme {

    public var name:String?
    
    var dictionary:[String: AnyObject]?
    
    public class func activeTheme() -> Theme? {
        return ThemeManager.sharedInstance.activeTheme
    }
    
    public init() {
        
    }
    
    func objectForKey(key:String) -> AnyObject? {
        let object:AnyObject? = self.dictionary![key]
        return object;
    }
    
    internal func setKeyAndObject(key:String, object:AnyObject) {
        self.dictionary = [key: object]
    }
    
    public func colorForKey(key:String, defaultValue:UIColor?) -> UIColor? {
        if let someColor = self.objectForKey(key) as? UIColor {
            return someColor
        }
        return defaultValue
    }
    
    public func stringForKey(key:String, defaultValue:String? = nil) -> String? {
        if let someString = self.objectForKey(key) as? String {
            return someString
        }
        return defaultValue
    }
    
    public func numberForKey(key:String, defaultValue:NSNumber? = nil) -> NSNumber? {
        if let someNumber = self.objectForKey(key) as? NSNumber {
            return someNumber
        }
        
        return defaultValue
    }
    
    public func boolForKey(key:String, defaultValue:Bool = false) -> Bool {
        if let someNumber = self.numberForKey(key) {
            return someNumber.boolValue
        }
        
        return defaultValue
    }
    
    public func floatForKey(key:String, defaultValue:Float = 0) -> Float {
        if let someNumber = self.numberForKey(key) {
            return someNumber.floatValue
        }
        
        return defaultValue
    }
    
}








