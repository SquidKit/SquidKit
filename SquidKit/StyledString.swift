//
//  StyledString.swift
//  SquidKit
//
//  Created by Mike Leavy on 4/21/16.
//  Copyright © 2016-2019 Squid Store, LLC. All rights reserved.
//

import Foundation

public class StyledString {
    
    fileprivate let editingString:NSMutableAttributedString!
    fileprivate var editingAttributes:[NSAttributedString.Key : Any]!
    public var count: Int {
        return editingString.length
    }
    
    public var attributedString:NSAttributedString {
        return self.editingString.copy() as! NSAttributedString
    }
    
    public init() {
        editingString = NSMutableAttributedString()
        editingAttributes = [NSAttributedString.Key : Any]()
    }
    
    public init(copyFrom:StyledString) {
        editingString = copyFrom.editingString
        editingAttributes = copyFrom.editingAttributes
    }
    
    @discardableResult
    public func pushString(_ string:String, seperator: String? = nil) -> StyledString {
        let attString = NSMutableAttributedString(string: string, attributes: editingAttributes)
        if count > 0, let seperator = seperator {
            let attSeperator = NSMutableAttributedString(string: seperator, attributes: editingAttributes)
            editingString.append(attSeperator)
        }
        editingString.append(attString)
        return self
    }
    
    @discardableResult
    public func pushAttributedString(_ string: NSAttributedString, seperator: NSAttributedString? = nil) -> StyledString {
        if count > 0, let seperator = seperator {
            editingString.append(seperator)
        }
        editingString.append(string)
        return self
    }
    
    @discardableResult
    public func pushAttributes(_ attributes:[NSAttributedString.Key : Any]) -> StyledString {
        editingAttributes.unionInPlace(attributes)
        return self
    }
    
    @discardableResult
    public func popAttributes(_ attributes:[NSAttributedString.Key]) -> StyledString {
        let _ = attributes.map {editingAttributes.removeValue(forKey: $0)}
        return self
    }
    
    @discardableResult
    public func pushColor(_ color:UIColor) -> StyledString {
        self.pushAttributes([NSAttributedString.Key.foregroundColor : color])
        return self
    }
    
    @discardableResult
    public func pushFont(_ font:UIFont, baselineOffset: Double? = nil) -> StyledString {
        if let baseline = baselineOffset {
            self.pushAttributes([NSAttributedString.Key.font : font, NSAttributedString.Key.baselineOffset: NSNumber(value: baseline)])
        }
        else {
            self.pushAttributes([NSAttributedString.Key.font : font])
        }
        return self
    }
    
    @discardableResult
    public func pushDefaultParagraphStyle() -> StyledString {
        pushAttributes([kCTParagraphStyleAttributeName as NSAttributedString.Key: NSParagraphStyle.default])
        return self
    }
    
    @discardableResult
    public func pushParagraphIndent(firstLineHeadIndent: CGFloat, headIndent: CGFloat) -> StyledString {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        
        paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
        paragraphStyle.headIndent = headIndent
        
        pushAttributes([kCTParagraphStyleAttributeName as NSAttributedString.Key: paragraphStyle])
        return self
    }
    
    @discardableResult
    public func pushParagraphAlignment(_ alignment: NSTextAlignment) -> StyledString {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        
        paragraphStyle.alignment = alignment
        
        pushAttributes([kCTParagraphStyleAttributeName as NSAttributedString.Key: paragraphStyle])
        return self
    }
    
    @discardableResult
    public func popParagraphStyle() -> StyledString {
        popAttributes([kCTParagraphStyleAttributeName as NSAttributedString.Key])
        return self
    }
    
    @discardableResult
    public func pushStrikethrough() -> StyledString {
        pushAttributes([NSAttributedString.Key.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)])
        return self
    }
    
    @discardableResult
    public func popStrikethrough() -> StyledString {
        popAttributes([NSAttributedString.Key.strikethroughStyle])
        return self
    }
    
}



public func + (left:StyledString, right:String) -> StyledString {
    var styled = StyledString(copyFrom: left)
    styled = styled.pushString(right)
    return styled
}

public func + (left:StyledString, right:[NSAttributedString.Key: Any]) -> StyledString {
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


public func - (left:StyledString, right:[NSAttributedString.Key]) -> StyledString {
    var styled = StyledString(copyFrom: left)
    styled = styled.popAttributes(right)
    return styled
}

private extension Dictionary {
    mutating func unionInPlace(_ dictionary: Dictionary) {
        dictionary.forEach { self.updateValue($0.1, forKey: $0.0) }
    }
}
