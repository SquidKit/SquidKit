//
//  StyledString.swift
//  SquidKit
//
//  Created by Mike Leavy on 4/21/16.
//  Copyright © 2016 SquidKit. All rights reserved.
//

import Foundation

public struct StyledString {
    
    private let editingString:NSMutableAttributedString!
    private var editingAttributes:[String : AnyObject]!
    
    var attributedString:NSAttributedString {
        return self.editingString.copy() as! NSAttributedString
    }
    
    public init() {
        editingString = NSMutableAttributedString()
        editingAttributes = [String : AnyObject]()
    }
    
    public init(copyFrom:StyledString) {
        editingString = copyFrom.editingString
        editingAttributes = copyFrom.editingAttributes
    }
    
    public func pushString(string:String) -> StyledString {
        let attString = NSMutableAttributedString(string: string, attributes: editingAttributes)
        editingString.appendAttributedString(attString)
        return self
    }
    
    public mutating func pushAttributes(attributes:[String : AnyObject]) -> StyledString {
        editingAttributes.unionInPlace(attributes)
        return self
    }
    
    public mutating func popAttributes(attributes:[String]) -> StyledString {
        let _ = attributes.map {editingAttributes.removeValueForKey($0)}
        return self
    }
    
    public mutating func pushColor(color:UIColor) -> StyledString {
        self.pushAttributes([NSForegroundColorAttributeName : color])
        return self
    }
    
    public mutating func pushFont(font:UIFont) -> StyledString {
        self.pushAttributes([NSFontAttributeName : font])
        return self
    }
    
}



public func + (left:StyledString, right:String) -> StyledString {
    var styled = StyledString(copyFrom: left)
    styled = styled.pushString(right)
    return styled
}

public func + (left:StyledString, right:[String : AnyObject]) -> StyledString {
    var styled = StyledString(copyFrom: left)
    styled = styled.pushAttributes(right)
    return styled
}

public func + (left:StyledString, right:UIColor) -> StyledString {
    var styled = StyledString(copyFrom: left)
    styled = styled.pushColor(right)
    return styled
}

public func + (left:StyledString, right:UIFont) -> StyledString {
    var styled = StyledString(copyFrom: left)
    styled = styled.pushFont(right)
    return styled
}


public func - (left:StyledString, right:[String]) -> StyledString {
    var styled = StyledString(copyFrom: left)
    styled = styled.popAttributes(right)
    return styled
}

private extension Dictionary {
    mutating func unionInPlace(dictionary: Dictionary) {
        dictionary.forEach { self.updateValue($1, forKey: $0) }
    }
}
