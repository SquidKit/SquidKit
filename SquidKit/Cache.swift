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
        
        NotificationCenter.default.addObserver(self, selector: #selector(CacheEntry.handleLowMemory(_:)), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
        clear()
    }
    
    @objc func handleLowMemory(_ notification:Notification?) {
        clear()
    }
    
    func clear () {
        self.cache.removeAllObjects()
    }
}

open class Cache<T:NSObject> {
    
    fileprivate var cacheEntry:CacheEntry?
    
    public init () {
        
        let cacheIdentifier = cacheIdentifierPrefix + NSStringFromClass(T.self)
        for cache in caches {
            if cacheIdentifier == cache.identifier as String {
                self.cacheEntry = cache
            }
        }
        
        if self.cacheEntry == nil {
            self.cacheEntry = CacheEntry(identifier:cacheIdentifier)
            caches.append(self.cacheEntry!)
        }
    }
    
    open func insert(_ object:T, key:AnyObject) {
        self.cacheEntry!.cache.setObject(object, forKey: key)
    }
    
    open func get(_ key:AnyObject) -> T? {
        return self.cacheEntry!.cache.object(forKey: key) as? T
    }
    
    open func get(_ request:URLRequest) -> T? {
        switch request.cachePolicy {
            case .reloadIgnoringLocalCacheData, .reloadIgnoringLocalAndRemoteCacheData:
                return nil
            default:
                break;
        }
        
        return self.get(request.url!)
    }
    
    open subscript(key:AnyObject) -> T? {
        return self.get(key)
    }
    
    open subscript(request:URLRequest) -> T? {
        return self.get(request)
    }
    
    open func clear () -> Void {
        self.cacheEntry?.clear()
    }
    
}
