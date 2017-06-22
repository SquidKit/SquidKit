//
//  KVObserving.swift
//  SquidKit
//
//  Created by Mike Leavy on 5/7/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import Foundation

// Facility to help with implementing KVO in Swift code. This isn't a KVO substitute, rather it relies on Objective-C KVO, thus participants must be
// NSObject-derived classes.

public typealias KVObservingBlock = (_ keyPath: String, _ object: AnyObject, _ change: [NSObject: AnyObject]) -> Void

@objc public protocol KVObserving {
    
    func observableObject(kvoHelper:KVOHelper) -> NSObject?
    
    @objc optional func observeValueForKeyPath(kvoHelper:KVOHelper, keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject])
    
}

open class KVOHelper : NSObject {
    
    static fileprivate var observerContext = 0
    
    fileprivate var keys = [String]()
    fileprivate var blockMap = [String: KVObservingBlock]()
    fileprivate unowned let observer:NSObject
    fileprivate unowned var observed:NSObject
    
    public init(observerObject:NSObject) {
        
        observer = observerObject
        observed = NSObject()
        
        super.init()
        
        if let observing:KVObserving = self.observer as? KVObserving , observing.observableObject(kvoHelper:self) != nil {
            observed = observing.observableObject(kvoHelper:self)!
        }        
        
    }
    
    deinit {
        for key in keys {
            observed.removeObserver(self, forKeyPath: key, context: &KVOHelper.observerContext)
        }
    }
    
    // register to observe a key path. callback will happen via the KVObserving protocol's observeValueForKeyPath method
    open func observe(keyPath:String) {
            if !keys.contains(keyPath) {
                observed.addObserver(self, forKeyPath: keyPath, options: .new, context: &KVOHelper.observerContext)
                keys.append(keyPath)
            }
    }
    
    // register to observe a key path, with specified callback block (KVObserving protocol not involved)
    open func observe(keyPath:String, block:@escaping KVObservingBlock) {
        if !keys.contains(keyPath) {
            observed.addObserver(self, forKeyPath: keyPath, options: .new, context: &KVOHelper.observerContext)
            keys.append(keyPath)
            blockMap[keyPath] = block
        }
    }
    
    // register to observe multiple key paths, with single specified callback block (KVObserving protocol not involved)
    open func observe(keyPaths:[String], block:@escaping KVObservingBlock) {
        for keyPath in keyPaths {
            self.observe(keyPath: keyPath, block: block)
        }
    }
    
    // unobserve a key path
    open func unobserve(_ keyPath:String) {
            if keys.contains(keyPath) {
                observed.removeObserver(self, forKeyPath: keyPath, context: &KVOHelper.observerContext)
                keys.remove(at: keys.index(of: keyPath)!)
                blockMap.removeValue(forKey: keyPath)
            }
    }
    
    
    open override func  observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let aKeyPath = keyPath, let anObject = object, let aChange = change else {
            return
        }
        if context == &KVOHelper.observerContext {
            if let observing:KVObserving = self.observer as? KVObserving {
                if let block = blockMap[aKeyPath] {
                    block(aKeyPath, anObject as AnyObject, aChange as [NSObject : AnyObject])
                }
                else {
                    observing.observeValueForKeyPath?(kvoHelper:self, keyPath: aKeyPath, ofObject: anObject as AnyObject, change: aChange as [NSObject : AnyObject])
                }
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}
