//
//  JSONEntity.swift
//  SquidKit
//
//  Created by Mike Leavy on 9/3/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation


public class JSONEntity: SequenceType {
    
    private struct Entity {
        var key:String
        var value:AnyObject
        
        init(_ key:String, _ value:AnyObject) {
            self.key = key
            self.value = value
        }
    }
    
    private var entity:Entity
    
    private class NilValue {
    }
    
    public var count:Int {
        if let array = self.array() {
            return array.count
        }
        return 0
    }
    
    public var isValid:Bool {
        if let e = self.entity.value as? NilValue {
            return false
        }
        return true
    }
    
    public var key:String {
        return self.entity.key
    }
    
    public init(_ key:String, _ value:AnyObject) {
        self.entity = Entity(key, value)
    }
    
    public init(resourceFilename:String) {
        if let dictionary = NSDictionary.dictionaryFromResourceFile(resourceFilename) {
            self.entity = Entity(resourceFilename, dictionary)
        }
        else {
            self.entity = Entity("", NilValue())
        }
    }
    
    public init(jsonDictionary:NSDictionary) {
        self.entity = Entity("", jsonDictionary)
    }
    
    public func string(_ defaultValue:String? = nil) -> String? {
        return EntityConverter<String>().get(entity.value, defaultValue)
    }
    
    public func array(_ defaultValue:NSArray? = nil) -> NSArray? {
        return EntityConverter<NSArray>().get(entity.value, defaultValue)
    }
    
    public func dictionary(_ defaultValue:NSDictionary? = nil) -> NSDictionary? {
        return EntityConverter<NSDictionary>().get(entity.value, defaultValue)
    }
    
    public func int(_ defaultValue:Int? = nil) -> Int? {
        if let int = EntityConverter<Int>().get(entity.value, nil) {
            return int
        }
        else if let intString = EntityConverter<String>().get(entity.value, nil) {
            return (intString as NSString).integerValue
        }
        return defaultValue
    }
    
    public func float(_ defaultValue:Float? = nil) -> Float? {
        if let float = EntityConverter<Float>().get(entity.value, nil) {
            return float
        }
        else if let floatString = EntityConverter<String>().get(entity.value, nil) {
            return (floatString as NSString).floatValue
        }
        return defaultValue
    }
    
    public func bool(_ defaultValue:Bool? = nil) -> Bool? {
        if let bool = EntityConverter<Bool>().get(entity.value, nil) {
            return bool
        }
        else if let boolString = EntityConverter<String>().get(entity.value, nil) {
            return (boolString as NSString).boolValue
        }
        return defaultValue
    }
    
    public subscript(key:String) -> JSONEntity {
        if let e:NSDictionary = entity.value as? NSDictionary {
            if let object:AnyObject = e.objectForKey(key) {
                return JSONEntity(key, object)
            }
        }
        return JSONEntity(key, NilValue())
    }
    
    public subscript(index:Int) -> JSONEntity? {
        if let array:NSArray = entity.value as? NSArray {
            return JSONEntity(self.entity.key, array[index])
        }
        return nil
    }
    
    public typealias GeneratorType = JSONEntityGenerator
    public func generate() -> GeneratorType {
        var generator = JSONEntityGenerator(self)
        return generator
    }
    
}

public struct JSONEntityGenerator:GeneratorType {
    public typealias Element = JSONEntity
    
    let entity:JSONEntity
    var sequenceIndex = 0
    
    public init(_ entity:JSONEntity) {
        self.entity = entity
    }
    
    public mutating func next() -> Element? {
        if let array = self.entity.array() {
            if sequenceIndex < array.count {
                let result = JSONEntity(self.entity.entity.key, array[sequenceIndex])
                sequenceIndex++
                return result
            }
            else {
                sequenceIndex = 0
            }
        }
        return .None
    }
}



private class EntityConverter<T> {
    init() {
    }
    
    func get(entity:AnyObject, _ defaultValue:T? = nil) -> T? {
        if let someEntity:T = entity as? T {
            return someEntity
        }
        return defaultValue
    }
}
