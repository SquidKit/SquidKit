//
//  Cache.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/4/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit


private var caches = [Any]()
private var cacheIdentifierPrefix = "com.squidkit.cache.type."

private class CacheEntry<KeyType:AnyObject, ObjectType:AnyObject> {
    var cache = NSCache<KeyType, ObjectType>()
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
        cache.removeAllObjects()
    }
    
    func insert(object:ObjectType, key:KeyType) {
        cache.setObject(object, forKey: key)
    }
    
    func remove(forKey:KeyType) {
        cache.removeObject(forKey: forKey)
    }
    
    func get(_ key:KeyType) -> ObjectType? {
        return cache.object(forKey: key)
    }
}

open class Cache<KeyType:AnyObject, ObjectType:AnyObject> {
    
    fileprivate var cacheEntry:CacheEntry<KeyType, ObjectType>?
    
    
    public init () {
        
        let cacheIdentifier = cacheIdentifierPrefix + String(describing: KeyType.self) + "." + String(describing: ObjectType.self)

        for cache in caches {
            guard let entry = cache as? CacheEntry<KeyType, ObjectType> else {continue}
            cacheEntry = entry
        }
        
        if cacheEntry == nil {
            cacheEntry = CacheEntry<KeyType, ObjectType>(identifier: cacheIdentifier)
            caches.append(cacheEntry!)
        }
    }
    
    open func insert(_ object:ObjectType, key:KeyType) {
        self.cacheEntry!.cache.setObject(object, forKey: key)
        cacheEntry?.insert(object: object, key: key)
    }
    
    open func get(_ key:KeyType) -> ObjectType? {
        return cacheEntry?.get(key)
    }
    
    open func get(_ key:String) -> ObjectType? {
        guard let keyString = key as? KeyType else {
            return nil
        }
        return cacheEntry?.get(keyString)
    }
    
    open func get(_ request:URLRequest) -> ObjectType? {
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
    
    open func remove(forKey:KeyType) {
        cacheEntry?.remove(forKey: forKey)
    }
    
    open subscript(key:KeyType) -> ObjectType? {
        return self.get(key)
    }
    
    open subscript(request:URLRequest) -> ObjectType? {
        return self.get(request)
    }
    
    open func clear () -> Void {
        self.cacheEntry?.clear()
    }
    
}
