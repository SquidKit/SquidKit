//
//  ThemeTableView.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/20/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

open class ThemeTableView: UITableView {

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
