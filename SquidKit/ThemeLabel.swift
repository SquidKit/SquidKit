//
//  ThemeLabel.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright © 2014-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

open class ThemeLabel: UILabel {

    @IBInspectable open var textColorName:String? = "defaultLabelTextColor" {
        didSet {
            self.updateTextColor()
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.updateTextColor()
    }
    
    fileprivate func updateTextColor() {
        if (self.textColorName != nil) {
            if let color = Theme.activeTheme()?.colorForKey(self.textColorName!, defaultValue: self.textColor) {
                self.textColor = color
            }
        }
    }

}
