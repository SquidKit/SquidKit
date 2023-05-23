//
//  ListString.swift
//  SquidKit
//
//  Created by Michael Leavy on 5/23/23.
//  Copyright © 2023 SquidKit. All rights reserved.
//

import UIKit

public class ListString {
    public enum ListStyle {
        case ordered
        case unordered(UnorderedCharacter)
    }
    
    public enum UnorderedCharacter {
        case dash
        case bullet
        case custom(Character)
        
        var character: Character {
            switch self {
            case .dash:
                return Character("-")
            case .bullet:
                return Character("•")
            case .custom(let character):
                return character
            }
        }
    }
    
    private let editingString: NSMutableAttributedString!
    private let listStyle: ListStyle
    private let tabSize: CGFloat
    private let lineSpacing: CGFloat
    
    public init(listStyle: ListStyle, tabSize: CGFloat = 5, lineSpacing: CGFloat = 5) {
        self.listStyle = listStyle
        self.editingString = NSMutableAttributedString()
        self.tabSize = tabSize
        self.lineSpacing = lineSpacing
    }
    
    public func list(strings: [String], font: UIFont) -> NSAttributedString {
        
        var prefixes = [String]()
        for i in 0..<strings.count {
            var prefix = ""
            switch listStyle {
            case .ordered:
                prefix = "\(i+1)."
            case .unordered(let character):
                prefix = String(character.character)
            }
            prefixes.append(prefix)
        }
        
        var maxPrefixWidth = CGFloat(0)
        for prefix in prefixes {
            let width = prefix.width(with: font)
            if width > maxPrefixWidth {
                maxPrefixWidth = width
            }
        }
        
        maxPrefixWidth += tabSize
                
        for i in 0..<strings.count {
            
            if i > 0 {
                editingString.append(NSAttributedString(string: "\n"))
            }
            
            let s = prefixes[i] + "\t" + strings[i]
            let item = NSMutableAttributedString.bulletedAttributedString(s,
                                                                          font: font,
                                                                          prefixWidth: maxPrefixWidth,
                                                                          lineSpacing: lineSpacing)
            editingString.append(item)
        }
        
        return editingString.copy() as! NSAttributedString
    }
}

private extension NSMutableAttributedString {
    static func bulletedAttributedString(_ source: String,
                                         font: UIFont,
                                         prefixWidth: CGFloat,
                                         lineSpacing: CGFloat) -> NSAttributedString {
        let attributed: NSMutableAttributedString = NSMutableAttributedString(string: source)
        let paragraphStyle = createParagraphAttribute(prefixWidth: prefixWidth, lineSpacing: lineSpacing)
        attributed.addAttributes([kCTParagraphStyleAttributeName as NSAttributedString.Key: paragraphStyle], range: NSMakeRange(0, attributed.length))
        attributed.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: font, range: NSMakeRange(0, attributed.length))
        return attributed
    }
    
    static func createParagraphAttribute(prefixWidth: CGFloat, lineSpacing: CGFloat) -> NSParagraphStyle {
        var paragraphStyle: NSMutableParagraphStyle
        paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        
        let tabStop = NSTextTab(textAlignment: .left, location: prefixWidth, options: [:])
        
        paragraphStyle.tabStops = [tabStop]
        paragraphStyle.defaultTabInterval = prefixWidth
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = prefixWidth
        paragraphStyle.lineSpacing = lineSpacing
        
        return paragraphStyle
    }
}

private extension String {
    func width(with font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: fontAttributes)
        return size.width
    }
}
