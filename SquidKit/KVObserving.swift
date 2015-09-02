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
    
    func observableObject(kvoHelper kvoHelper:KVOHelper) -> NSObject?
    
    optional func observeValueForKeyPath(kvoHelper kvoHelper:KVOHelper, keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject])
    
}

public class KVOHelper : NSObject {
    
    static private var observerContext = 0
    
    private var keys = [String]()
    private var blockMap = [String: KVObservingBlock]()
    private unowned let observer:NSObject
    private unowned var observed:NSObject
    
    public init(observerObject:NSObject) {
        
        observer = observerObject
        observed = NSObject()
        
        super.init()
        
        if let observing:KVObserving = self.observer as? KVObserving where observing.observableObject(kvoHelper:self) != nil {
            observed = observing.observableObject(kvoHelper:self)!
        }        
        
    }
    
    deinit {
        for key in keys {
            observed.removeObserver(self, forKeyPath: key, context: &KVOHelper.observerContext)
        }
    }
    
    // register to observe a key path. callback will happen via the KVObserving protocol's observeValueForKeyPath method
    public func observe(keyPath keyPath:String) {
            if !keys.contains(keyPath) {
                observed.addObserver(self, forKeyPath: keyPath, options: .New, context: &KVOHelper.observerContext)
                keys.append(keyPath)
            }
    }
    
    // register to observe a key path, with specified callback block (KVObserving protocol not involved)
    public func observe(keyPath keyPath:String, block:KVObservingBlock) {
        if !keys.contains(keyPath) {
            observed.addObserver(self, forKeyPath: keyPath, options: .New, context: &KVOHelper.observerContext)
            keys.append(keyPath)
            blockMap[keyPath] = block
        }
    }
    
    // register to observe multiple key paths, with single specified callback block (KVObserving protocol not involved)
    public func observe(keyPaths keyPaths:[String], block:KVObservingBlock) {
        for keyPath in keyPaths {
            self.observe(keyPath: keyPath, block: block)
        }
    }
    
    // unobserve a key path
    public func unobserve(keyPath:String) {
            if keys.contains(keyPath) {
                observed.removeObserver(self, forKeyPath: keyPath, context: &KVOHelper.observerContext)
                keys.removeAtIndex(keys.indexOf(keyPath)!)
                blockMap.removeValueForKey(keyPath)
            }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let aKeyPath = keyPath, anObject = object, aChange = change else {
            return
        }
        if context == &KVOHelper.observerContext {
            if let observing:KVObserving = self.observer as? KVObserving {
                if let block = blockMap[aKeyPath] {
                    block(keyPath: aKeyPath, object: anObject, change: aChange)
                }
                else {
                    observing.observeValueForKeyPath?(kvoHelper:self, keyPath: aKeyPath, ofObject: anObject, change: aChange)
                }
            }
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}