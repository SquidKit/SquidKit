//
//  Preferences.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/29/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public class Preferences {
    
    public init() {
        
    }
    
    // OVERRIDE to return a different NSUserDefaults (such as a shared defaults if you're working on an extension or suite)
    public var userDefaults:NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
    
    public func setPreference(object:NSSecureCoding?, key:String) {
        if let objectToSet:NSSecureCoding = object {
            self.userDefaults.setObject(objectToSet, forKey: key)
            self.userDefaults.synchronize()
        }
        else {
            self.remove(key)
        }
    }
    
    public func setBool(object:Bool?, key:String) {
        if let boolToSet:Bool = object {
            self.userDefaults.setObject(NSNumber(bool: boolToSet), forKey: key)
            self.userDefaults.synchronize()
        }
        else {
            self.remove(key)
        }
    }
    
    public func setInt(object:Int?, key:String) {
        if let intToSet:Int = object {
            self.userDefaults.setObject(NSNumber(integer: intToSet), forKey: key)
            self.userDefaults.synchronize()
        }
        else {
            self.remove(key)
        }
    }
    
    public func setFloat(object:Float?, key:String) {
        if let floatToSet:Float = object {
            self.userDefaults.setObject(NSNumber(float: floatToSet), forKey: key)
            self.userDefaults.synchronize()
        }
        else {
            self.remove(key)
        }
    }
    
    public func preference(key:String) -> AnyObject? {
        return self.userDefaults.objectForKey(key)
    }
    
    public func boolValue(key:String, defaultValue:Bool) -> Bool {
        if let result = self.userDefaults.objectForKey(key) as? NSNumber {
            return result.boolValue
        }
        return defaultValue
    }
    
    public func intValue(key:String, defaultValue:Int) -> Int {
        if let result = self.userDefaults.objectForKey(key) as? NSNumber {
            return result.integerValue
        }
        return defaultValue
    }
    
    public func floatValue(key:String, defaultValue:Float) -> Float {
        if let result = self.userDefaults.objectForKey(key) as? NSNumber {
            return result.floatValue
        }
        return defaultValue
    }
        
    public func remove(key:String) {
        self.userDefaults.removeObjectForKey(key)
        self.userDefaults.synchronize()
    }
}

public class Preference<T:NSSecureCoding> {
    
    public init() {
        
    }
    
    public func get(key:String, defaultValue:T) -> T {
        if let pref = Preferences().preference(key) as? T {
            return pref
        }
        return defaultValue
    }
    
    public func get(key:String) -> T? {
        if let pref = Preferences().preference(key) as? T {
            return pref
        }
        return nil
    }
}

