//
//  Preferences.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/29/14.
//  Copyright © 2014-2019 Squid Store, LLC. All rights reserved.
//

import Foundation

open class Preferences {
    
    public init() {
        
    }
    
    // OVERRIDE to return a different NSUserDefaults (such as a shared defaults if you're working on an extension or suite)
    open var userDefaults:UserDefaults {
        return UserDefaults.standard
    }
    
    open func setPreference(_ object:Any?, key:String) {
        if let objectToSet:Any = object {
            self.userDefaults.set(objectToSet, forKey: key)
            self.userDefaults.synchronize()
        }
        else {
            self.remove(key)
        }
    }
    
    open func setBool(_ object:Bool?, key:String) {
        if let boolToSet:Bool = object {
            self.userDefaults.set(NSNumber(value: boolToSet), forKey: key)
            self.userDefaults.synchronize()
        }
        else {
            self.remove(key)
        }
    }
    
    open func setInt(_ object:Int?, key:String) {
        if let intToSet:Int = object {
            self.userDefaults.set(NSNumber(value: intToSet), forKey: key)
            self.userDefaults.synchronize()
        }
        else {
            self.remove(key)
        }
    }
    
    open func setFloat(_ object:Float?, key:String) {
        if let floatToSet:Float = object {
            self.userDefaults.set(NSNumber(value: floatToSet), forKey: key)
            self.userDefaults.synchronize()
        }
        else {
            self.remove(key)
        }
    }
    
    open func setString(_ object:String?, key:String) {
        if let stringToSet:String = object {
            self.userDefaults.set(stringToSet as NSString, forKey: key)
            self.userDefaults.synchronize()
        }
        else {
            self.remove(key)
        }
    }
    
    open func preference(_ key:String) -> Any? {
        return self.userDefaults.object(forKey: key) as Any?
    }
    
    open func boolValue(_ key:String, defaultValue:Bool) -> Bool {
        if let result = self.userDefaults.object(forKey: key) as? NSNumber {
            return result.boolValue
        }
        return defaultValue
    }
    
    open func intValue(_ key:String, defaultValue:Int) -> Int {
        if let result = self.userDefaults.object(forKey: key) as? NSNumber {
            return result.intValue
        }
        return defaultValue
    }
    
    open func floatValue(_ key:String, defaultValue:Float) -> Float {
        if let result = self.userDefaults.object(forKey: key) as? NSNumber {
            return result.floatValue
        }
        return defaultValue
    }
    
    open func stringValue(_ key:String, defaultValue:String?) -> String? {
        if let result = self.userDefaults.object(forKey: key) as? String {
            return result
        }
        return defaultValue
    }
        
    open func remove(_ key:String) {
        self.userDefaults.removeObject(forKey: key)
        self.userDefaults.synchronize()
    }
}

open class Preference<T:Any> {
    
    public init() {
        
    }
    
    open func set(_ object:T, key:String) {
        Preferences().setPreference(object, key: key)
    }
    
    open func get(_ key:String, defaultValue:T) -> T {
        if let pref = Preferences().preference(key) as? T {
            return pref
        }
        return defaultValue
    }
    
    open func get(_ key:String) -> T? {
        if let pref = Preferences().preference(key) as? T {
            return pref
        }
        return nil
    }
}

