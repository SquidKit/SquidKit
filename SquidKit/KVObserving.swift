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

public typealias KVObservingBlock = (keyPath: String, object: AnyObject, change: [NSObject: AnyObject]) -> Void

@objc public protocol KVObserving {
    
    func observableObject() -> NSObject?
    
    optional func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject])
    
}

public class KVOHelper : NSObject {
    
    static private var observerContext = 0
    
    private var keys = [String]()
    private var blockMap = [String: KVObservingBlock]()
    private unowned let observer:NSObject
    private unowned let observed:NSObject
    
    public init(observer:NSObject) {
        
        self.observer = observer
        
        if let observing:KVObserving = self.observer as? KVObserving where observing.observableObject() != nil {
            observed = observing.observableObject()!
        }
        else {
            observed = NSObject()
        }
        
        super.init()
    }
    
    deinit {
        for key in keys {
            observed.removeObserver(self, forKeyPath: key, context: &KVOHelper.observerContext)
        }
    }
    
    // register to observe a key path. callback will happen via the KVObserving protocol's observeValueForKeyPath method
    public func observe(#keyPath:String) {
            if !contains(keys, keyPath) {
                observed.addObserver(self, forKeyPath: keyPath, options: .New, context: &KVOHelper.observerContext)
                keys.append(keyPath)
            }
    }
    
    // register to observe a key path, with specified callback block (KVObserving protocol not involved)
    public func observe(#keyPath:String, block:KVObservingBlock) {
        if !contains(keys, keyPath) {
            observed.addObserver(self, forKeyPath: keyPath, options: .New, context: &KVOHelper.observerContext)
            keys.append(keyPath)
            blockMap[keyPath] = block
        }
    }
    
    // register to observe multiple key paths, with single specified callback block (KVObserving protocol not involved)
    public func observe(#keyPaths:[String], block:KVObservingBlock) {
        for keyPath in keyPaths {
            self.observe(keyPath: keyPath, block: block)
        }
    }
    
    // unobserve a key path
    public func unobserve(keyPath:String) {
            if contains(keys, keyPath) {
                observed.removeObserver(self, forKeyPath: keyPath, context: &KVOHelper.observerContext)
                keys.removeAtIndex(find(keys, keyPath)!)
                blockMap.removeValueForKey(keyPath)
            }
    }
    
    override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &KVOHelper.observerContext {
            if let observing:KVObserving = self.observer as? KVObserving {
                if let block = blockMap[keyPath] {
                    block(keyPath: keyPath, object: object, change: change)
                }
                else {
                    observing.observeValueForKeyPath?(keyPath, ofObject: object, change: change)
                }
            }
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}