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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let accessoryView = KeyboardAccessoryBar()
        accessoryView.addDismisser(systemItem: .done, for: textField, with: .left)
        textField.inputAccessoryView = accessoryView
        
        textField.editingChangedClosure = { [weak self] text in
            self?.textFieldChangedLabel.text = text
        }
        
    }
}
