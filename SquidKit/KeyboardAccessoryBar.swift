//
//  KeyboardAccessoryBar.swift
//  SquidKit
//
//  Created by Mike Leavy on 12/18/17.
//  Copyright © 2017-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

open class KeyboardAccessoryBar: UIToolbar {
    
    public enum Alignment {
        case left
        case right
    }
    
    open weak var dismissResponder: UIResponder?
    open weak var followOnResponder: UIResponder?
    open weak var followOnResponder2: UIResponder?

    open var height: CGFloat = 35 {
        didSet {
            frame = CGRect(x: 0, y: 0, width: 0, height: height)
        }
    }
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setDismisser(title: String, for responder: UIResponder, with alignment: Alignment?) {
        let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.didTapDismisser(_:)))
        addItem(item: item, with: alignment)
        dismissResponder = responder
    }
    
    public func setDismisser(systemItem: UIBarButtonItem.SystemItem, for responder: UIResponder, with alignment: Alignment?) {
        let item = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(self.didTapDismisser(_:)))
        addItem(item: item, with: alignment)
        dismissResponder = responder
    }
    
    public func setFollowOn(title: String, for followOnResponder: UIResponder, with alignment: Alignment?) {
        let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.didTapFollowOn(_:)))
        addItem(item: item, with: alignment)
        self.followOnResponder = followOnResponder
    }
    
    public func set(previousTitle: String?, previousResponder: UIResponder?, nextTitle: String?, nextResponder: UIResponder?, dismisser: UIBarButtonItem.SystemItem?, dismisserResponder: UIResponder?, enableFlags: (Bool, Bool, Bool)? = nil) {
        var items = [UIBarButtonItem]()
        if let title = previousTitle, let responder = previousResponder {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.didTapFollowOn2(_:)))
            if let flags = enableFlags, !flags.0 {
                item.isEnabled = false
            }
            items.append(item)
            followOnResponder2 = responder
        }
        
        if let title = nextTitle, let responder = nextResponder {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.didTapFollowOn(_:)))
            if let flags = enableFlags, !flags.1 {
                item.isEnabled = false
            }
            items.append(item)
            self.followOnResponder = responder
        }
        
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        
        if let dismisser = dismisser {
            let item = UIBarButtonItem(barButtonSystemItem: dismisser, target: self, action: #selector(self.didTapDismisser(_:)))
            if let flags = enableFlags, !flags.2 {
                item.isEnabled = false
            }
            items.append(item)
            dismissResponder = dismisserResponder
        }
        
        setItems(items, animated: false)
    }
    
    public func set(previousImage: UIImage?, previousResponder: UIResponder?, nextImage: UIImage?, nextResponder: UIResponder?, nextPreviousSpaceCount: Int, dismisser: UIBarButtonItem.SystemItem?, dismisserResponder: UIResponder?, enableFlags: (Bool, Bool, Bool)? = nil) {
        var items = [UIBarButtonItem]()
        
        var previousItem: UIBarButtonItem?
        var nextItem: UIBarButtonItem?
        
        if let image = previousImage, let responder = previousResponder {
            previousItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.didTapFollowOn2(_:)))
            if let flags = enableFlags, !flags.0 {
                previousItem?.isEnabled = false
            }
            followOnResponder2 = responder
        }
        
        if let image = nextImage, let responder = nextResponder {
            nextItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.didTapFollowOn(_:)))
            if let flags = enableFlags, !flags.1 {
                nextItem?.isEnabled = false
            }
            self.followOnResponder = responder
        }
        
        if let previous = previousItem {
            items.append(previous)
        }
        
        if previousItem != nil && nextItem != nil {
            for _ in 0..<nextPreviousSpaceCount {
                items.append(UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil))
            }
        }
                
        if let next = nextItem {
            items.append(next)
        }
        
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        
        if let dismisser = dismisser {
            let item = UIBarButtonItem(barButtonSystemItem: dismisser, target: self, action: #selector(self.didTapDismisser(_:)))
            if let flags = enableFlags, !flags.2 {
                item.isEnabled = false
            }
            items.append(item)
            dismissResponder = dismisserResponder
        }
        
        setItems(items, animated: false)
    }
    
    fileprivate func addItem(item: UIBarButtonItem, with alignment: Alignment?) {
        var items = [UIBarButtonItem]()
        
        if let a = alignment {
            switch a {
            case .left:
                items.append(item)
                items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            case .right:
                items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                items.append(item)
            }
        }
        else {
            items.append(item)
        }
        
        setItems(items, animated: false)
    }
    
    
    @objc func didTapDismisser(_ sender: Any) {
        dismissResponder?.resignFirstResponder()
    }
    
    @objc func didTapFollowOn(_ sender: Any) {
        followOnResponder?.becomeFirstResponder()
    }
    
    @objc func didTapFollowOn2(_ sender: Any) {
        followOnResponder2?.becomeFirstResponder()
    }
    
}
