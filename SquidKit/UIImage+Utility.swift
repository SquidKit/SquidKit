//
//  UIImage+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 7/9/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit

public extension UIImage {
   
    class func imageFromView(view:UIView, rect:CGRect, scaleForDevice:Bool = true) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scaleForDevice ? 0.0 : 1.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let scale = scaleForDevice ? UIScreen.mainScreen().scale : 1.0
        let imageRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * scale, rect.size.height * scale)
        let imageRef = CGImageCreateWithImageInRect(viewImage.CGImage, imageRect)
        
        var resultImage = UIImage(CGImage: imageRef)
        
        return resultImage
    }
    
    func imageWithInsets(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width + insets.left + insets.right, self.size.height + insets.top + insets.bottom), false, self.scale)
        
        self.drawAtPoint(CGPoint(x: insets.left, y: insets.top))
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return imageWithInsets
    }
}


