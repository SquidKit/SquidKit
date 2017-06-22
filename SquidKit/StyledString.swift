//
//  StyledString.swift
//  SquidKit
//
//  Created by Mike Leavy on 4/21/16.
//  Copyright © 2016 SquidKit. All rights reserved.
//

import Foundation

public struct StyledString {
    
    fileprivate let editingString:NSMutableAttributedString!
    fileprivate var editingAttributes:[String : AnyObject]!
    
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
    
    @discardableResult
    public func pushString(_ string:String) -> StyledString {
        let attString = NSMutableAttributedString(string: string, attributes: editingAttributes)
        editingString.append(attString)
        return self
    }
    
    @discardableResult
    public mutating func pushAttributes(_ attributes:[String : AnyObject]) -> StyledString {
        editingAttributes.unionInPlace(attributes)
        return self
    }
    
    public mutating func popAttributes(_ attributes:[String]) -> StyledString {
        let _ = attributes.map {editingAttributes.removeValue(forKey: $0)}
        return self
    }
    
    public mutating func pushColor(_ color:UIColor) -> StyledString {
        self.pushAttributes([NSForegroundColorAttributeName : color])
        return self
    }
    
    public mutating func pushFont(_ font:UIFont) -> StyledString {
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
    mutating func unionInPlace(_ dictionary: Dictionary) {
        dictionary.forEach { self.updateValue($1, forKey: $0) }
    }
}
