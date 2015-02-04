//
//  Cache.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/4/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import Foundation


private var caches = [AnyObject]()



public class AnyCache<T:NSObject> {
    
    private var cache: NSCache
    
    public init () {
        cache = NSCache()
        Log.message("new cache for \(self)")
    }
    
    public func insert(object:T, key:String) {
        self.cache.setObject(object, forKey: key)
    }
    
    public func get(key:String) -> T? {
        return self.cache.objectForKey(key) as? T
    }
    
    public func cacheFor() -> AnyCache<T> {
        var result = AnyCache<T>()
        Log.message("this is \(result)")
        return result
    }
}


public extension NSObject {
    
    public class func cacheFor<T:NSObject>() -> AnyCache<T> {
        for cache in caches {
//            if let matchingCache = cache as? AnyCache<T> {
//                return matchingCache
//            }
            
            let klass: T.Type = T.self
            Log.message("klass is \(klass)")
            if cache is AnyCache<T> {
                return cache as AnyCache<T>
            }
        }
        
        let newCache = AnyCache<T>()
        caches.append(newCache)
        
        return newCache
    }
    
}


private var allcaches = [AnyObject]()

private struct CacheEntry {
    var cache = NSCache()
    var identifier:NSString
    private static let cacheIdentifierPrefix = "com.squidkit.cache.type."
    
    init(identifier:String) {
        self.identifier = CacheEntry.cacheIdentifierPrefix + identifier
    }
}

public class Cache<T:NSObject> {
    
    private var cache: NSCache?
    
    
    public init () {
        
        Log.message("my dumb type is \(NSStringFromClass(T.self))")
        
        for cache in allcaches {
            if let matchingCache = cache as? Cache<T> {
                self.cache = matchingCache.cache
            }
        }
        
        if self.cache == nil {
            self.cache = NSCache()
            allcaches.append(self)
            Log.message("new dumb cache for \(self)")
        }
        
        
    }
    
    public func insert(object:T, key:String) {
        self.cache!.setObject(object, forKey: key)
    }
    
    public func get(key:String) -> T? {
        return self.cache!.objectForKey(key) as? T
    }
    
}
