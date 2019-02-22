//
//  UIImage+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 7/9/15.
//  Copyright © 2017-2019 Squid Store, LLC. All rights reserved.
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
    
    func scaledImage(withSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func scaleImageToFitSize(size: CGSize) -> UIImage {
        let aspect = self.size.width / self.size.height
        if size.width / aspect <= size.height {
            return scaledImage(withSize: CGSize(width: size.width, height: size.width / aspect))
        } else {
            return scaledImage(withSize: CGSize(width: size.height * aspect, height: size.height))
        }
    }
    
    func colorized(color : UIColor, blendMode: CGBlendMode = .screen) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {return self}
        guard let cgImage = cgImage else {return self}
        context.setBlendMode(blendMode)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: rect)
        context.clip(to: rect, mask: cgImage)
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return colorizedImage ?? self
    }
}


