//
//  JSONExtractor.swift
//  SquidKit
//
//  Created by Mike Leavy on 9/3/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public class JSONExtractor {
    public let jsonEntity:JSONEntity?
    
    public init(resourceFilename:String) {
        if let dictionary = NSDictionary.dictionaryFromResourceFile(resourceFilename) {
            jsonEntity = JSONEntity(dictionary)
        }
        else {
            jsonEntity = JSONEntity(JSONEntity.NoEntity())
        }
    }
    
    public class JSONEntity {
        
        private var entity:AnyObject
        
        private class NoEntity {
            
        }
        
        private init(_ entity:AnyObject) {
            self.entity = entity
        }
        
        public func string(_ defaultValue:String? = nil) -> String? {
            if let s:String = entity as? String {
                return s
            }
            return defaultValue
        }
        
        public func array(_ defaultValue:NSArray? = nil) -> NSArray? {
            if let a:NSArray = entity as? NSArray {
                return a
            }
            return defaultValue
        }
        
        public func dictionary(_ defaultValue:NSDictionary? = nil) -> NSDictionary? {
            if let d:NSDictionary = entity as? NSDictionary {
                return d
            }
            return defaultValue
        }
        
        public func int(_ defaultValue:Int? = nil) -> Int? {
            if let i:Int = entity as? Int {
                return i
            }
            return defaultValue
        }
        
        public func float(_ defaultValue:Float? = nil) -> Float? {
            if let f:Float = entity as? Float {
                return f
            }
            return defaultValue
        }
        
        public func bool(_ defaultValue:Bool? = nil) -> Bool? {
            if let b:Bool = entity as? Bool {
                return b
            }
            return defaultValue
        }
        
        public subscript(key:String) -> JSONEntity {
            if let e:NSDictionary = entity as? NSDictionary {
                if let object:AnyObject = e.objectForKey(key) {
                    return JSONEntity(object)
                }
            }
            return JSONEntity(NoEntity())
        }
        
        public subscript(index:Int) -> JSONEntity? {
            if let a:NSArray = entity as? NSArray {
                return JSONEntity(a[index])
            }
            return nil
        }
    }
}

private class EntityConverter<T:AnyObject> {
    init() {
        
    }
    
    func get(entity:AnyObject, _ defaultValue:T? = nil) -> T? {
        if let b:T = entity as? T {
            return b
        }
        return defaultValue
    }
}
