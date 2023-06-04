//
//  StyledStringViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 11/14/18.
//  Copyright © 2018 SquidKit. All rights reserved.
//

import UIKit
import SquidKit

class StyledStringViewController: UIViewController {
    
    enum View: Int {
        case misc = 0
        case ordered
        case unordered
        
        var text: NSAttributedString {
            switch self {
            case .misc:
                let styled = StyledString().pushFont(UIFont.systemFont(ofSize: 16))
                    .pushColor(.black)
                    .pushString("Hello\n\n")
                    .pushParagraphIndent(firstLineHeadIndent: 20, headIndent: 10)
                    .pushString("Paragraph head first line indent with a value of 20, and paragraph head indent with a value of 10\n\n")
                    .popParagraphStyle()
                    .pushColor(.red)
                    .pushStrikethrough().pushString("Strikethrough")
                    .popStrikethrough()
                    .pushColor(.black)
                    .pushString("\n\n")
                    .pushUnderline()
                    .pushString("Underlined")
                    .pushString("\n\n")
                    .pushUnderline(.double)
                    .pushString("Double Underlined")
                    .popUnderline()
                    .pushParagraphAlignment(.center)
                    .pushString("\n\nCentered Alignment")
                    .pushDefaultParagraphStyle()
                    if #available(iOS 13, *) {
                        styled.pushSystemFont(8)
                            .pushString(" ")
                            .pushImage(UIImage(systemName: "trash.circle"))
                    }
                    styled.pushKern(12)
                    .pushSystemFont(18, weight: .bold)
                    .pushString("\n\nGoodbye")
                
                return styled.attributedString
            case .ordered, .unordered:
                var strings =
                    ["hello",
                     "this is a list of strings",
                     "this is a very long string that will need to wrap on some displays (hopefully, this one)",
                     "goodbye"]
                
                for i in 0..<200 {
                    strings.append("\(i)")
                }
                
                let list = ListString(listStyle: self == .ordered ? .ordered : .unordered(.custom("😍")))
                let listString = list.list(strings: strings, font: UIFont.systemFont(ofSize: 17))
                return listString
            }
        }
    }

    @IBOutlet weak var textView: UITextView!
    
    var styleView: View = .misc {
        didSet {
            textView.attributedText = styleView.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleView = .misc
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        guard let style = View(rawValue: sender.selectedSegmentIndex) else {return}
        styleView = style
    }

}
