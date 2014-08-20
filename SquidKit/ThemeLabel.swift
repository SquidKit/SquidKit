//
//  ThemeLabel.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright (c) 2014 SquidStore. All rights reserved.
//

import UIKit

class ThemeLabel: UILabel {

    var textColorName:String? = "defaultLabelTextColor" {
        didSet {
            self.updateTextColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.updateTextColor()
    }
    
    private func updateTextColor() {
        if (self.textColorName != nil) {
            if let color = Theme.activeTheme()?.colorForKey(self.textColorName!, defaultValue: self.textColor) {
                self.textColor = color
            }
        }
    }

}
