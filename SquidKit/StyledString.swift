//
//  StyledString.swift
//  SquidKit
//
//  Created by Mike Leavy on 4/21/16.
//  Copyright © 2016-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

public class StyledString {
    
    fileprivate let editingString: NSMutableAttributedString!
    fileprivate var editingAttributes: [NSAttributedString.Key : Any]!
    public var count: Int {
        return editingString.length
    }
    
    public var attributedString: NSAttributedString {
        return self.editingString.copy() as! NSAttributedString
    }
    
    public init() {
        editingString = NSMutableAttributedString()
        editingAttributes = [NSAttributedString.Key : Any]()
    }
    
    public init(copyFrom: StyledString) {
        editingString = copyFrom.editingString
        editingAttributes = copyFrom.editingAttributes
    }
    
    /**
     Initialize a StyledString with format. Similar to Swift's String(format: String, arguments: CVarArg...)
     initializer, with the addition of a variadic argument of style attributes. The currently supported  style format
     specifiers and their associated style attributes are:
        #F, #f - font, represented as a UIFont object
            #C, #c - color, represented as a UIColor object
            #I, #i - image, represented as a UIImage object
            ## - # symbol
     
     Example:
        StyledString(format: "#FHello, #Cworld", arguments: nil, styleArguments: UIFont.systemFont(ofSize: 15), UIColor.blue)
     
        which produces the string "Hello, world" rendered with a system font of size 15, with the word "world" rendered with the blue color
     
    Note: font and color specifiers remain in effect throught the run of the string, unless/until a new specifier for font or color is encountered
    */
    @available(iOS 13, *)
    public convenience init(format: String, arguments: CVarArg..., styleArguments: AnyObject?...) {
        self.init()
        let workingString = String(format: format, arguments)
        
        
        var formatObjects: [AnyObject?] = []
        for arg in styleArguments {
            formatObjects.append(arg)
        }
        
        var isCandidate = false
        for char in workingString {
            if isCandidate {
                isCandidate = false
                switch char {
                case "#":
                    pushCharacter(char)
                case "f", "F":
                    guard let font = formatObjects.first as? UIFont else {
                        continue
                    }
                    pushFont(font)
                    formatObjects.removeFirst()
                case "c", "C":
                    guard let color = formatObjects.first as? UIColor else {
                        continue
                    }
                    pushColor(color)
                    formatObjects.removeFirst()
                case "i", "I":
                    guard let image = formatObjects.first as? UIImage else {
                        continue
                    }
                    pushImage(image)
                    formatObjects.removeFirst()
                default:
                    pushCharacter(char)
                }
                continue
            }
            if char == "#" {
                isCandidate = true
            } else {
                pushCharacter(char)
            }
        }
    }
    
    @discardableResult
    public func pushCharacter(_ character: Character, seperator: String? = nil) -> StyledString {
        let attString = NSMutableAttributedString(string: String(character), attributes: editingAttributes)
        if count > 0, let seperator = seperator {
            let attSeperator = NSMutableAttributedString(string: seperator, attributes: editingAttributes)
            editingString.append(attSeperator)
        }
        editingString.append(attString)
        return self
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
    
    @available(iOS 13, *)
    @discardableResult
    public func pushImage(_ image: UIImage?, color: UIColor? = nil) -> StyledString {
        guard let image else {return self}
        let imageAttachment = NSTextAttachment()
        var _image = image
        if let color {
            _image = image.withTintColor(color)
        }
        else {
            if let color = editingAttributes[NSAttributedString.Key.foregroundColor] as? UIColor {
                _image = image.withTintColor(color)
            }
        }
        imageAttachment.image = _image
        editingString.append(NSAttributedString(attachment: imageAttachment))
        return self
    }
    
    @discardableResult
    public func pushKern(_ kern: CGFloat) -> StyledString {
        self.pushAttributes([NSAttributedString.Key.kern: kern])
        return self
    }
    
    @discardableResult
    public func popKern(_ kern: CGFloat) -> StyledString {
        self.popAttributes([NSAttributedString.Key.kern])
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
    public func pushSystemFont(_ size: CGFloat, weight: UIFont.Weight = .regular, baselineOffset: Double? = nil) -> StyledString {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
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
    public func pushParagraphSpacing(_ spacing: CGFloat, isBefore: Bool = false) -> StyledString {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        
        if isBefore {
            paragraphStyle.paragraphSpacingBefore = spacing
        }
        else {
            paragraphStyle.paragraphSpacing = spacing
        }
        
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
    
    @discardableResult
    public func pushUnderline(_ style: NSUnderlineStyle = .single) -> StyledString {
        pushAttributes([NSAttributedString.Key.underlineStyle: NSNumber(value: style.rawValue)])
        return self
    }
    
    @discardableResult
    public func popUnderline() -> StyledString {
        popAttributes([NSAttributedString.Key.underlineStyle])
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
