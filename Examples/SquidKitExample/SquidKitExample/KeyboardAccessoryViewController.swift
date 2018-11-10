//
//  KeyboardAccessoryViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 12/18/17.
//  Copyright © 2017 SquidKit. All rights reserved.
//

import SquidKit

class KeyboardAccessoryViewController: UIViewController {

    @IBOutlet weak var textField: TextFieldEditingChanged!
    @IBOutlet weak var textFieldChangedLabel: UILabel!
    @IBOutlet weak var nextTextField: UITextField!
    @IBOutlet weak var lastTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nextAccessoryView = KeyboardAccessoryBar()
        nextAccessoryView.setFollowOn(title: "Next", for: nextTextField, with: .right)
        textField.inputAccessoryView = nextAccessoryView
        
        let middleAccessoryView = KeyboardAccessoryBar()
        middleAccessoryView.set(previousTitle: "Prev", previousResponder: textField, nextTitle: "Next", nextResponder: lastTextField, dismisser: .done, dismisserResponder: nextTextField, enableFlags: (false, true, true))
        nextTextField.inputAccessoryView = middleAccessoryView
        
        let doneAccessoryView = KeyboardAccessoryBar()
        doneAccessoryView.setDismisser(systemItem: .done, for: lastTextField, with: .right)
        lastTextField.inputAccessoryView = doneAccessoryView
        
        textField.editingChangedClosure = { [weak self] text in
            self?.textFieldChangedLabel.text = text
        }
        
    }
}
