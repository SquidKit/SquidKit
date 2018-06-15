//
//  Cache.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/4/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import Foundation

fileprivate struct CacheManager {
    static var caches = [Any]()
}


fileprivate class CacheType<KeyType:AnyObject, ObjectType:AnyObject> {
    var cache = NSCache<KeyType, ObjectType>()
    var identifier:String
    
    init(identifier:String) {
        self.identifier = identifier
        
        NotificationCenter.default.addObserver(self, selector: #selector(CacheType.handleLowMemory(_:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
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
    
    fileprivate var cacheType:CacheType<KeyType, ObjectType>?
    
    public init () {
        
        let cacheIdentifier = "com.squidkit.cache.type" + String(describing: KeyType.self) + "." + String(describing: ObjectType.self)

        for cache in CacheManager.caches {
            guard let entry = cache as? CacheType<KeyType, ObjectType> else {continue}
            cacheType = entry
        }
        
        if cacheType == nil {
            cacheType = CacheType<KeyType, ObjectType>(identifier: cacheIdentifier)
            CacheManager.caches.append(cacheType!)
        }
    }
    
    open func insert(_ object:ObjectType, key:KeyType) {
        cacheType!.cache.setObject(object, forKey: key)
        cacheType?.insert(object: object, key: key)
    }
    
    open func get(_ key:KeyType) -> ObjectType? {
        return cacheType?.get(key)
    }
    
    open func get(_ key:String) -> ObjectType? {
        guard let keyString = key as? KeyType else {
            return nil
        }
        return cacheType?.get(keyString)
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
        
        return get(url.absoluteString)
    }
    
    open func remove(forKey:KeyType) {
        cacheType?.remove(forKey: forKey)
    }
    
    open subscript(key:KeyType) -> ObjectType? {
        return get(key)
    }
    
    open subscript(request:URLRequest) -> ObjectType? {
        return get(request)
    }
    
    open func clear () -> Void {
        cacheType?.clear()
    }
    
}
