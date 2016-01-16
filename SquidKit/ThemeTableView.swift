//
//  ThemeTableView.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/20/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

public class ThemeTableView: UITableView {

    @IBInspectable public var backgroundColorName:String? = "defaultBackgroundColor" {
        didSet {
            self.updateBackgroundColor()
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.updateBackgroundColor()
    }
    
    private func updateBackgroundColor() {
        if (self.backgroundColorName != nil) {
            if let color = Theme.activeTheme()?.colorForKey(self.backgroundColorName!, defaultValue: self.backgroundColor) {
                self.backgroundColor = color
            }
        }
    }
}
