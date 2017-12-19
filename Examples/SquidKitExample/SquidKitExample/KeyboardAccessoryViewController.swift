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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nextAccessoryView = KeyboardAccessoryBar()
        nextAccessoryView.addFollowOn(title: "Next", for: nextTextField, with: .right)
        textField.inputAccessoryView = nextAccessoryView
        
        let doneAccessoryView = KeyboardAccessoryBar()
        doneAccessoryView.addDismisser(systemItem: .done, for: nextTextField, with: .right)
        nextTextField.inputAccessoryView = doneAccessoryView
        
        textField.editingChangedClosure = { [weak self] text in
            self?.textFieldChangedLabel.text = text
        }
        
    }
}
