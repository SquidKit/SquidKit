//
//  EmbossedText.swift
//  SquidKit
//
//  Created by Mike Leavy on 10/26/18.
//  Copyright © 2018-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

public struct EmbossedText {
    
    public static func emboss(_ text: String, font: UIFont, color: UIColor, texture: UIImage, useHeightMap: Bool) -> UIImage? {
        let styled = StyledString().pushFont(font).pushColor(color).pushString(text)
        return emboss(styled.attributedString, texture: texture, useHeightMap: useHeightMap)
    }
    
    public static func emboss(_ text: NSAttributedString, texture: UIImage, useHeightMap: Bool) -> UIImage? {
        let image = UIImage
            .image(from: text)?
            .applyEmboss(shadingImage: texture, useHeightMap: useHeightMap)
        return image
    }
}

public extension UIImage {
    public class func image(from string: String, attributes: [NSAttributedString.Key: Any]?, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        string.draw(with: rect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public class func image(from string: NSAttributedString) -> UIImage? {
        let size = string.size()
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        string.draw(with: rect, options: .usesLineFragmentOrigin, context: nil)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public func applyEmboss(shadingImage: UIImage, useHeightMap: Bool = true) -> UIImage {
        // Create filters
        guard let shadedMaterialFilter = CIFilter(name: "CIShadedMaterial") else { return self }
        if useHeightMap {
            guard let heightMapFilter = CIFilter(name: "CIHeightFieldFromMask") else { return self }
            heightMapFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
            guard let heightMapFilterOutput = heightMapFilter.outputImage else { return self }
            shadedMaterialFilter.setValue(heightMapFilterOutput, forKey: kCIInputImageKey)
        }
        else {
            shadedMaterialFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        }
        
        shadedMaterialFilter.setValue(CIImage(image: shadingImage), forKey: "inputShadingImage")
        
        // Output
        guard let filteredImage = shadedMaterialFilter.outputImage else { return self }
        return UIImage(ciImage: filteredImage)
    }
}
