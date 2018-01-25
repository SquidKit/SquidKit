//
//  UIView+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit

public extension UIView {
    
    public class func preserveBackgroundColors(views: [UIView], closure: () -> Void) {
        let viewColorPairs = views.map { (view) -> (UIView, UIColor?) in
            return (view, view.backgroundColor)
        }
        closure()
        for (view, color) in viewColorPairs {
            view.backgroundColor = color
        }
    }
    
    public func centerInView(_ containingView:UIView) {
        var rect = self.frame
        rect.origin.x = floor(containingView.bounds.origin.x + (containingView.bounds.size.width - rect.size.width) / 2)
        rect.origin.y = floor(containingView.bounds.origin.y + (containingView.bounds.size.height - rect.size.height) / 2)
        
        self.frame = rect
    }
}


