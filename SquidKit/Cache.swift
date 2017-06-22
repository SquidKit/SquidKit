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
    var cache = Cache()
    var identifier:String
    
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
        cache.clear()
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
        self.cacheEntry!.cache.insert(object, key: key)
    }
    
    open func get(_ key:AnyObject) -> T? {
        return self.cacheEntry!.cache.get(key) as? T
    }
    
    open func get(_ key:String) -> T? {
        return self.cacheEntry!.cache.get(key) as? T
    }
    
    open func get(_ request:URLRequest) -> T? {
        switch request.cachePolicy {
            case .reloadIgnoringLocalCacheData, .reloadIgnoringLocalAndRemoteCacheData:
                return nil
            default:
                break;
        }
        
        guard let url = request.url else {
            return nil
        }
        
        return self.get(url.absoluteString)
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
