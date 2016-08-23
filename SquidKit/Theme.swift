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

public protocol ThemeManagerLoggable {
    func log<T>(_ output:@autoclosure () -> T?)
}

open class ThemeManager {
    
    var themes = [String: Theme]()
    
    var activeTheme:Theme? {
        didSet {
            if let loaggable = self as? ThemeManagerLoggable {
                loaggable.log("Active theme is now: \(activeTheme?.name)")
            }
        }
    }
    
    open class var sharedInstance: ThemeManager {
        return _ThemeManagerSharedInstance
    }
    
    public init() {
        
    }
    
    open func setActiveThemeByName(_ name:String) {
        
        if let foundTheme = themes[name] {
            self.activeTheme = foundTheme
        }
        else {
            self.setDefaultTheme()
        }
    }
    
    open func setDefaultTheme() {
        if themes.count > 0 {
            var arrayOfKeys:[String] = Array(themes.keys)
            arrayOfKeys = arrayOfKeys.sorted()
            self.activeTheme = themes[arrayOfKeys[0]]
        }
    }
    
    open func updateThemedSubviewsOfView(_ view:UIView, recursive:Bool = true) {
        for aView in view.subviews {
            aView.setNeedsDisplay()
            if (recursive) {
                self.updateThemedSubviewsOfView(aView , recursive: true)
            }
        }
    }

}

open class Theme {

    open var name:String?
    
    var dictionary:[String: AnyObject]?
    
    open class func activeTheme() -> Theme? {
        return ThemeManager.sharedInstance.activeTheme
    }
    
    open class func anyTheme() -> Theme {
        if let activeTheme = ThemeManager.sharedInstance.activeTheme {
            return activeTheme
        }
        return Theme()
    }
    
    public init() {
        
    }
    
    func objectForKey(_ key:String) -> AnyObject? {
        let object:AnyObject? = self.dictionary![key]
        return object;
    }
    
    internal func setKeyAndObject(_ key:String, object:AnyObject) {
        self.dictionary = [key: object]
    }
    
    open func colorForKey(_ key:String, defaultValue:UIColor?) -> UIColor? {
        if let someColor = self.objectForKey(key) as? UIColor {
            return someColor
        }
        return defaultValue
    }
    
    open func stringForKey(_ key:String, defaultValue:String? = nil) -> String? {
        if let someString = self.objectForKey(key) as? String {
            return someString
        }
        return defaultValue
    }
    
    open func numberForKey(_ key:String, defaultValue:NSNumber? = nil) -> NSNumber? {
        if let someNumber = self.objectForKey(key) as? NSNumber {
            return someNumber
        }
        
        return defaultValue
    }
    
    open func boolForKey(_ key:String, defaultValue:Bool = false) -> Bool {
        if let someNumber = self.numberForKey(key) {
            return someNumber.boolValue
        }
        
        return defaultValue
    }
    
    open func floatForKey(_ key:String, defaultValue:Float = 0) -> Float {
        if let someNumber = self.numberForKey(key) {
            return someNumber.floatValue
        }
        
        return defaultValue
    }
    
    open func intForKey(_ key:String, defaultValue:Int = 0) -> Int {
        if let someNumber = self.numberForKey(key) {
            return someNumber.intValue
        }
        
        return defaultValue
    }
    
}








