//
//  Alamofire+Image.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit

public extension Request {
    
    public static func imageResponseSerializer(decompressImage: Bool = true) -> GenericResponseSerializer<UIImage> {
        return GenericResponseSerializer { request, response, data in
            if data == nil || response == nil {
                let failureReason = (data == nil) ? "Input data was nil" : "URL response was nil"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(data, error)
            }
            
            if decompressImage {
                if let image = self.decompressImage(response! as NSHTTPURLResponse, data: data!) {
                    return .Success(image)
                }
                else {
                    let failureReason = "Image failed to decompress"
                    let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                    return .Failure(data, error)
                }
            } else {
                if let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale) {
                    return .Success(image)
                }
                else {
                    let failureReason = "Failed to initialize UIImage from data"
                    let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                    return .Failure(data, error)
                }
            }
        }
    }
    
    
    func responseImageCacheable(completion: (NSURLRequest?, NSHTTPURLResponse?, UIImage?) -> Void) -> Self {
        if let httpRequest = request, let cachedImage = Cache<UIImage>()[httpRequest] {
            completion(httpRequest, nil, cachedImage)
            return self
        }
        
        let serializer = Request.imageResponseSerializer()
        return response(responseSerializer: serializer, completionHandler: { request, response, result in
            switch (result) {
            case let .Success(image):
                Cache<UIImage>().insert(image, key: request!.URL!)
                completion(request, response, image)
            case .Failure(_, _):
                completion(request, response, nil)
            }
        })
    }
    
    func responseImage(completion: (NSURLRequest?, NSHTTPURLResponse?, UIImage?) -> Void) -> Self {
        let serializer = Request.imageResponseSerializer()
        return response(responseSerializer: serializer, completionHandler: { request, response, result in
            switch (result) {
            case let .Success(image):
                completion(request, response, image)
            case .Failure(_, _):
                completion(request, response, nil)
            }
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
            imageRef = CGImageCreateWithPNGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
            
        } else if response.MIMEType == "image/jpeg" {
            imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
            
            // CGImageCreateWithJPEGDataProvider does not properly handle CMKY, so if so,
            // fall back to AFImageWithDataAtScale
            if imageRef != nil {
                let imageColorSpace = CGImageGetColorSpace(imageRef)
                let imageColorSpaceModel = CGColorSpaceGetModel(imageColorSpace)
                switch (imageColorSpaceModel) {
                case .CMYK:
                    imageRef = nil
                default:
                    break
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
        var bitmapInfo:UInt32 = CGImageGetBitmapInfo(imageRef).rawValue
        if colorSpaceModel == .RGB {
            if alphaInfo == .None {
                bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask.rawValue
                bitmapInfo |= CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipFirst.rawValue).rawValue
            } else if (!(alphaInfo == .NoneSkipFirst || alphaInfo == .NoneSkipLast)) {
                bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask.rawValue
                bitmapInfo |= CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue).rawValue
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
        return UIImage(CGImage: inflatedImageRef!, scale: scale, orientation: image!.imageOrientation)
    }
}
