//
//  Cache.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/4/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit


private var caches = [CacheEntry]()
private var cacheIdentifierPrefix = "com.squidkit.cache.type."

private class CacheEntry {
    var cache = NSCache()
    var identifier:NSString
    
    init(identifier:String) {
        self.identifier = identifier
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLowMemory:", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        clear()
    }
    
    @objc func handleLowMemory(notification:NSNotification?) {
        clear()
    }
    
    func clear () {
        self.cache.removeAllObjects()
    }
}

public class Cache<T:NSObject> {
    
    private var cacheEntry:CacheEntry?
    
    public init () {
        
        let cacheIdentifier = cacheIdentifierPrefix + NSStringFromClass(T.self)
        for cache in caches {
            if cacheIdentifier == cache.identifier {
                self.cacheEntry = cache
            }
        }
        
        if self.cacheEntry == nil {
            self.cacheEntry = CacheEntry(identifier:cacheIdentifier)
            caches.append(self.cacheEntry!)
        }
    }
    
    public func insert(object:T, key:AnyObject) {
        self.cacheEntry!.cache.setObject(object, forKey: key)
    }
    
    public func get(key:AnyObject) -> T? {
        return self.cacheEntry!.cache.objectForKey(key) as? T
    }
    
    public func get(request:NSURLRequest) -> T? {
        switch request.cachePolicy {
            case .ReloadIgnoringLocalCacheData, .ReloadIgnoringLocalAndRemoteCacheData:
                return nil
            default:
                break;
        }
        
        return self.get(request.URL!)
    }
    
    public subscript(key:AnyObject) -> T? {
        return self.get(key)
    }
    
    public subscript(request:NSURLRequest) -> T? {
        return self.get(request)
    }
    
    public func clear () -> Void {
        self.cacheEntry?.clear()
    }
    
}
