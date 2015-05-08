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

public protocol KVObserving {
    
    func observableObject() -> NSObject?
    
    func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject])
    
}

public class KVOHelper : NSObject {
    
    static private var observerContext = 0
    
    private var keys = [String]()
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
    
    public func observe(keyPath:String) {
            if !contains(keys, keyPath) {
                observed.addObserver(self, forKeyPath: keyPath, options: .New, context: &KVOHelper.observerContext)
                keys.append(keyPath)
            }
    }
    
    public func unobserve(keyPath:String) {
            if contains(keys, keyPath) {
                observed.removeObserver(self, forKeyPath: keyPath, context: &KVOHelper.observerContext)
                keys.removeAtIndex(find(keys, keyPath)!)
            }
    }
    
    override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &KVOHelper.observerContext {
            if let observing:KVObserving = self.observer as? KVObserving {
                observing.observeValueForKeyPath(keyPath, ofObject: object, change: change)
            }
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
}