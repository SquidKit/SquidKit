//
//  JSONExtractor.swift
//  SquidKit
//
//  Created by Mike Leavy on 9/3/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public class JSONExtractor {
    public let jsonEntity:JSONEntity
    
    public init(resourceFilename:String) {
        if let dictionary = NSDictionary.dictionaryFromResourceFile(resourceFilename) {
            jsonEntity = JSONEntity(dictionary)
        }
        else {
            jsonEntity = JSONEntity(JSONEntity.NoEntity())
        }
    }
    
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
        
        public init(_ entity:AnyObject) {
            self.entity = entity
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
            return EntityConverter<Int>().get(entity, defaultValue)
        }
        
        public func float(_ defaultValue:Float? = nil) -> Float? {
            return EntityConverter<Float>().get(entity, defaultValue)
        }
        
        public func bool(_ defaultValue:Bool? = nil) -> Bool? {
            return EntityConverter<Bool>().get(entity, defaultValue)
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
        
        public typealias GeneratorType = JSONEntityGenerator
        public func generate() -> GeneratorType {
            var gen = JSONEntityGenerator(self)
            return gen
        }
        
    }
}

public struct JSONEntityGenerator:GeneratorType {
    public typealias Element = JSONExtractor.JSONEntity
    
    let entity:JSONExtractor.JSONEntity
    var sequenceIndex = 0
    
    public init(_ entity:JSONExtractor.JSONEntity) {
        self.entity = entity
    }
    
    public mutating func next() -> Element? {
        if let array = self.entity.array() {
            if sequenceIndex < array.count {
                let result = JSONExtractor.JSONEntity(array[sequenceIndex])
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
        if let b:T = entity as? T {
            return b
        }
        return defaultValue
    }
}
