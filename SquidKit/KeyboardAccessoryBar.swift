//
//  KeyboardAccessoryBar.swift
//  SquidKit
//
//  Created by Mike Leavy on 12/18/17.
//  Copyright © 2017 SquidKit. All rights reserved.
//

import UIKit

open class KeyboardAccessoryBar: UIToolbar {
    
    public enum Alignment {
        case left
        case right
    }
    
    open weak var responder: UIResponder?

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
    
    public func addDismisser(title: String, for responder: UIResponder, with alignment: Alignment?) {
        let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.didTapDismisser(_:)))
        addDismisserItem(item: item, for: responder, with: alignment)
    }
    
    public func addDismisser(systemItem: UIBarButtonSystemItem, for responder: UIResponder, with alignment: Alignment?) {
        let item = UIBarButtonItem(barButtonSystemItem: systemItem, target: self, action: #selector(self.didTapDismisser(_:)))
        addDismisserItem(item: item, for: responder, with: alignment)
    }
    
    fileprivate func addDismisserItem(item: UIBarButtonItem, for responder: UIResponder, with alignment: Alignment?) {
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
        self.responder = responder
    }
    
    @objc func didTapDismisser(_ sender: Any) {
        responder?.resignFirstResponder()
    }
    
}
