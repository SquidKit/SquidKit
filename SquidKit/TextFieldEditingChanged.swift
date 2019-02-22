//
//  TextFieldEditingChanged.swift
//  SquidKit
//
//  Created by Mike Leavy on 12/18/17.
//  Copyright © 2017-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

public typealias TextFieldEditingChangedClosure = (String?) -> Void

open class TextFieldEditingChanged: UITextField {
    
    public var editingChangedClosure: TextFieldEditingChangedClosure? {
        didSet {
            addTarget(self, action: #selector(self.editingChanged(_:)), for: .editingChanged)
        }
    }
    
    @objc func editingChanged(_ sender: Any) {
        guard let textField = sender as? UITextField else {return}
        if let c = editingChangedClosure {
            c(textField.text)
        }
    }

}
