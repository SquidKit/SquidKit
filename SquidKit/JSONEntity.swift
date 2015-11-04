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
        else if let dictionary = self.dictionary() {
            return dictionary.count
        }
        return 0
    }
    
    public var isValid:Bool {
        if let _ = self.entity.value as? NilValue {
            return false
        }
        return true
    }
    
    public var key:String {
        return self.entity.key
    }
    
    public var realValue:AnyObject? {
        if let _ = self.entity.value as? NilValue {
            return nil
        }
        return self.entity.value
    }
    
    public init () {
        self.entity = Entity("", NilValue())
    }
    
    public init(_ key:String, _ value:AnyObject) {
        self.entity = Entity(key, value)
    }
    
    public init(resourceFilename:String) {
        let jsonEntity = JSONEntity.entityFromResourceFile(resourceFilename)
        self.entity = jsonEntity.entity;
    }
    
    public init(jsonDictionary:NSDictionary) {
        self.entity = Entity("", jsonDictionary)
    }
    
    public init(jsonArray:NSArray) {
        self.entity = Entity("", jsonArray)
    }
    
    public func string() -> String? {
        return self.stringWithDefault(nil)
    }
    
    public func array() -> NSArray? {
        return self.arrayWithDefault(nil)
    }
    
    public func dictionary() -> NSDictionary? {
        return self.dictionaryWithDefault(nil)
    }
    
    public func int() -> Int? {
        return self.intWithDefault(nil)
    }
    
    public func float() -> Float? {
        return self.floatWithDefault(nil)
    }
    
    public func bool() -> Bool? {
        return self.boolWithDefault(nil)
    }
    
    public func stringWithDefault(defaultValue:String?) -> String? {
        return EntityConverter<String>().get(entity.value, defaultValue)
    }
    
    public func arrayWithDefault(defaultValue:NSArray?) -> NSArray? {
        return EntityConverter<NSArray>().get(entity.value, defaultValue)
    }
    
    public func dictionaryWithDefault(defaultValue:NSDictionary?) -> NSDictionary? {
        return EntityConverter<NSDictionary>().get(entity.value, defaultValue)
    }
    
    public func intWithDefault(defaultValue:Int?) -> Int? {
        if let int = EntityConverter<Int>().get(entity.value, nil) {
            return int
        }
        else if let intString = EntityConverter<String>().get(entity.value, nil) {
            return (intString as NSString).integerValue
        }
        return defaultValue
    }
    
    public func floatWithDefault(defaultValue:Float?) -> Float? {
        if let float = EntityConverter<Float>().get(entity.value, nil) {
            return float
        }
        else if let floatString = EntityConverter<String>().get(entity.value, nil) {
            return (floatString as NSString).floatValue
        }
        return defaultValue
    }
    
    public func boolWithDefault(defaultValue:Bool?) -> Bool? {
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
        let generator = JSONEntityGenerator(self)
        return generator
    }
    
}

public extension JSONEntity {
    
    public class func entityFromResourceFile(fileName:String) -> JSONEntity {
        var result:JSONEntity?
        
        if let inputStream = NSInputStream(fileAtPath:String.stringWithPathToResourceFile(fileName)) {
            inputStream.open()
            do {
                let serialized = try NSJSONSerialization.JSONObjectWithStream(inputStream, options:NSJSONReadingOptions(rawValue: 0))
                
                if let serializedASDictionary = serialized as? NSDictionary {
                    result = JSONEntity(jsonDictionary: serializedASDictionary)
                }
                else if let serializedAsArray = serialized as? NSArray {
                    result = JSONEntity(jsonArray: serializedAsArray)
                }
                else {
                    result = JSONEntity()
                }
            }
            catch {
                result = JSONEntity()
            }
            
            inputStream.close()
        }
        else {
            result = JSONEntity()
        }
        
        return result!
    }
}

public extension JSONEntity {
    
    enum JSONEntityError:ErrorType {
        case InvalidJSON
    }
    
    // this can be useful when deserializing elements directly into something like
    // Realm, which dies if it encounters null values
    public func entityWithoutNullValues() throws -> JSONEntity {
        if let array = self.array() {
            let mutableArray = NSMutableArray(array: array)
            return JSONEntity(jsonArray:mutableArray)
        }
        else if let dictionary = self.dictionary() {
            let mutableDictionary = NSMutableDictionary(dictionary: dictionary)
            return JSONEntity(jsonDictionary: mutableDictionary)
        }
        
        throw JSONEntityError.InvalidJSON
    }
    
    func removeNull(dictionary:NSMutableDictionary) {
        for key in dictionary.allKeys {
            let key = key as! String
            if let _ = dictionary[key] as? NSNull {
                dictionary.removeObjectForKey(key)
            }
            else if let arrayElement = dictionary[key] as? NSArray {
                let mutableArray = NSMutableArray(array: arrayElement)
                dictionary.setObject(mutableArray, forKey: key)
                self.removeNull(mutableArray)
            }
            else if let dictionaryElement = dictionary[key] as? NSDictionary {
                let mutableDictionary = NSMutableDictionary(dictionary: dictionaryElement)
                dictionary.setObject(mutableDictionary, forKey: key)
                self.removeNull(mutableDictionary)
            }
        }
    }
    
    func removeNull(array:NSMutableArray) {
        for element in array {
            if let dictionary = element as? NSDictionary {
                let mutableDictionary = NSMutableDictionary(dictionary: dictionary)
                array.replaceObjectAtIndex(array.indexOfObject(dictionary), withObject: mutableDictionary)
                self.removeNull(mutableDictionary)
            }
        }
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
        else if let dictionary = self.entity.dictionary() {
            if sequenceIndex < dictionary.count {
                let result = JSONEntity(dictionary.allKeys[sequenceIndex] as! String, dictionary.objectForKey(dictionary.allKeys[sequenceIndex])!)
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
