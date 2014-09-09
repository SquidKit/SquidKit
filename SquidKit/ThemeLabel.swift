//
//  ThemeLabel.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

public class ThemeLabel: UILabel {

    public var textColorName:String? = "defaultLabelTextColor" {
        didSet {
            self.updateTextColor()
        }
    }
    
    public override func awakeFromNib() {
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
