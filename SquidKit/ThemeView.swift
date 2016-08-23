//
//  ThemeView.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

open class ThemeView: UIView {
    
    @IBInspectable open var backgroundColorName:String? = "defaultBackgroundColor" {
        didSet {
            self.updateBackgroundColor()
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.updateBackgroundColor()
    }
    
    fileprivate func updateBackgroundColor() {
        if (self.backgroundColorName != nil) {
            if let color = Theme.activeTheme()?.colorForKey(self.backgroundColorName!, defaultValue: self.backgroundColor) {
                self.backgroundColor = color
            }
        }
    }
}
