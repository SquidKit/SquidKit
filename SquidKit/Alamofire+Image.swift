//
//  Alamofire+Image.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit

public extension Request {
    
    class func imageResponseSerializer(decompressImage: Bool = true) -> GenericResponseSerializer<UIImage> {
        return GenericResponseSerializer { request, response, data in
            if data == nil || response == nil {
                return (nil, nil)
            }
            
            if decompressImage {
                return (self.decompressImage(response! as NSHTTPURLResponse, data: data!), nil)
            } else {
                return (UIImage(data: data!, scale: UIScreen.mainScreen().scale), nil)
            }
        }
    }
    
    
    func responseImageCacheable(completion: (NSURLRequest, NSHTTPURLResponse?, UIImage?) -> Void) -> Self {
        if let cachedImage = Cache<UIImage>()[request] {
            completion(request, nil, cachedImage)
            return self
        }
        
        let serializer = Request.imageResponseSerializer()
        return response(responseSerializer: serializer, completionHandler: { request, response, image, error in
            if let cacheImage = image {
                Cache<UIImage>().insert(cacheImage, key: request.URL!)
            }
            completion(request, response, image)
        })
    }
    
    func responseImage(completion: (NSURLRequest, NSHTTPURLResponse?, UIImage?) -> Void) -> Self {
        let serializer = Request.imageResponseSerializer()
        return response(responseSerializer: serializer, completionHandler: { request, response, image, error in
            completion(request, response, image)
        })
    }
    
    // MARK: Private methods
    // From AFNetworking, as ported to Swift by Martin Conte Mac Donell (Reflejo@gmail.com) on 2/3/15.
    // Copyright (c) 2013-2015 Lyft (http://lyft.com)
    // also here: https://github.com/Alamofire/Alamofire/pull/333
    
    private class func decompressImage(response: NSHTTPURLResponse, data: NSData) -> UIImage? {
        if data.length == 0 {
            return nil
        }
        
        let dataProvider = CGDataProviderCreateWithCFData(data)
        
        var imageRef: CGImageRef?
        if response.MIMEType == "image/png" {
            imageRef = CGImageCreateWithPNGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
            
        } else if response.MIMEType == "image/jpeg" {
            imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
            
            // CGImageCreateWithJPEGDataProvider does not properly handle CMKY, so if so,
            // fall back to AFImageWithDataAtScale
            if imageRef != nil {
                let imageColorSpace = CGImageGetColorSpace(imageRef)
                let imageColorSpaceModel = CGColorSpaceGetModel(imageColorSpace)
                if imageColorSpaceModel.value == kCGColorSpaceModelCMYK.value {
                    imageRef = nil
                }
            }
        }
        
        let scale = UIScreen.mainScreen().scale
        let image = UIImage(data: data, scale: scale)
        if imageRef == nil || image == nil {
            if image == nil || image?.images != nil {
                return image
            }
            
            imageRef = CGImageCreateCopy(image!.CGImage)
            if imageRef == nil {
                return nil
            }
        }
        
        let width = CGImageGetWidth(imageRef)
        let height = CGImageGetHeight(imageRef)
        let bitsPerComponent = CGImageGetBitsPerComponent(imageRef)
        
        if width * height > 1024 * 1024 || bitsPerComponent > 8 {
            return image
        }
        
        let bytesPerRow = CGImageGetBytesPerRow(imageRef)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorSpaceModel = CGColorSpaceGetModel(colorSpace)
        let alphaInfo = CGImageGetAlphaInfo(imageRef)
        var bitmapInfo = CGImageGetBitmapInfo(imageRef)
        if colorSpaceModel.value == kCGColorSpaceModelRGB.value {
            if alphaInfo == .None {
                bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask
                bitmapInfo |= CGBitmapInfo(CGImageAlphaInfo.NoneSkipFirst.rawValue)
            } else if (!(alphaInfo == .NoneSkipFirst || alphaInfo == .NoneSkipLast)) {
                bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask
                bitmapInfo |= CGBitmapInfo(CGImageAlphaInfo.PremultipliedFirst.rawValue)
            }
        }
        
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow,
            colorSpace, bitmapInfo)
        if context == nil {
            return image
        }
        
        let drawRect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        CGContextDrawImage(context, drawRect, imageRef)
        let inflatedImageRef = CGBitmapContextCreateImage(context)
        return UIImage(CGImage: inflatedImageRef, scale: scale, orientation: image!.imageOrientation)
    }
}
