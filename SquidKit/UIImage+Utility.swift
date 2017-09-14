//
//  UIImage+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 7/9/15.
//  Copyright (c) 2017 SquidKit. All rights reserved.
//

import UIKit

public extension UIImage {
   
    class func imageFromView(_ view:UIView, rect:CGRect, scaleForDevice:Bool = true) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scaleForDevice ? 0.0 : 1.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let scale = scaleForDevice ? UIScreen.main.scale : 1.0
        let imageRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * scale, height: rect.size.height * scale)
        let imageRef = (viewImage?.cgImage)?.cropping(to: imageRect)
        
        let resultImage = UIImage(cgImage: imageRef!)
        
        return resultImage
    }
    
    func imageWithInsets(_ insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width + insets.left + insets.right, height: self.size.height + insets.top + insets.bottom), false, self.scale)
        
        self.draw(at: CGPoint(x: insets.left, y: insets.top))
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return imageWithInsets!
    }
}


