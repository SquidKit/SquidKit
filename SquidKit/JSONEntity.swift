//
//  JSONEntity.swift
//  SquidKit
//
//  Created by Mike Leavy on 9/3/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation


public class JSONEntity: SequenceType {
    
    private var entity:AnyObject
    
    private class NoEntity {
    }
    
    public var count:Int {
        if let array = self.array() {
            return array.count
        }
        return 0
    }
    
    public var isValid:Bool {
        if let e = self.entity as? NoEntity {
            return false
        }
        return true
    }
    
    public init(_ entity:AnyObject) {
        self.entity = entity
    }
    
    public init(resourceFilename:String) {
        if let dictionary = NSDictionary.dictionaryFromResourceFile(resourceFilename) {
            self.entity = dictionary
        }
        else {
            self.entity = NoEntity()
        }
    }
    
    public init(jsonDictionary:NSDictionary) {
        self.entity = jsonDictionary
    }
    
    public func string(_ defaultValue:String? = nil) -> String? {
        return EntityConverter<String>().get(entity, defaultValue)
    }
    
    public func array(_ defaultValue:NSArray? = nil) -> NSArray? {
        return EntityConverter<NSArray>().get(entity, defaultValue)
    }
    
    public func dictionary(_ defaultValue:NSDictionary? = nil) -> NSDictionary? {
        return EntityConverter<NSDictionary>().get(entity, defaultValue)
    }
    
    public func int(_ defaultValue:Int? = nil) -> Int? {
        if let int = EntityConverter<Int>().get(entity, nil) {
            return int
        }
        else if let intString = EntityConverter<String>().get(entity, nil) {
            return (intString as NSString).integerValue
        }
        return defaultValue
    }
    
    public func float(_ defaultValue:Float? = nil) -> Float? {
        if let float = EntityConverter<Float>().get(entity, nil) {
            return float
        }
        else if let floatString = EntityConverter<String>().get(entity, nil) {
            return (floatString as NSString).floatValue
        }
        return defaultValue
    }
    
    public func bool(_ defaultValue:Bool? = nil) -> Bool? {
        if let bool = EntityConverter<Bool>().get(entity, nil) {
            return bool
        }
        else if let boolString = EntityConverter<String>().get(entity, nil) {
            return (boolString as NSString).boolValue
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
        if let array:NSArray = entity as? NSArray {
            return JSONEntity(array[index])
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
                let result = JSONEntity(array[sequenceIndex])
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
