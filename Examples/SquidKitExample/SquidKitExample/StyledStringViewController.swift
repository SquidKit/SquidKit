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

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            .pushParagraphAlignment(.center)
            .pushString("\n\nCentered Alignment")
            .pushDefaultParagraphStyle()
            .pushString("\n\nGoodbye")
        

        textView.attributedText = styled.attributedString
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
