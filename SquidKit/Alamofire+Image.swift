//
//  Alamofire+Image.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit
import Alamofire

let SquidKitImageErrorDomain = "com.squidkit.error"

public extension Request {
    
    static func imageResponseSerializer(decompressImage: Bool = true, cacheImage: Bool = false) -> ResponseSerializer<UIImage, NSError> {
        return ResponseSerializer { request, response, data, error in
            
            guard error == nil else {
                return .Failure(error!)
            }
            
            if data == nil || response == nil {
                let failureReason = (data == nil) ? "Input data was nil" : "URL response was nil"
                let error = Error.error(domain: SquidKitImageErrorDomain, code: .DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            if decompressImage {
                if let image = self.decompressImage(response! as NSHTTPURLResponse, data: data!) {
                    if cacheImage {
                        Cache<UIImage>().insert(image, key: request!.URL!)
                    }
                    return .Success(image)
                }
                else {
                    let failureReason = "Image failed to decompress"
                    let error = Error.error(domain: SquidKitImageErrorDomain, code: .DataSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                }
            } else {
                if let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale) {
                    if cacheImage {
                        Cache<UIImage>().insert(image, key: request!.URL!)
                    }
                    return .Success(image)
                }
                else {
                    let failureReason = "Failed to initialize UIImage from data"
                    let error = Error.error(domain: SquidKitImageErrorDomain, code: .DataSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                }
            }
        }
    }
    
    
    func responseImageCacheable(_ completionHandler: (Response<UIImage, NSError>) -> Void) -> Self {
        if let httpRequest = request, let cachedImage = Cache<UIImage>()[httpRequest] {
            let result:Result<UIImage, NSError> = .Success(cachedImage)
            let response = Response<UIImage, NSError>(request:httpRequest, response:nil, data:nil, result:result)
            completionHandler(response)
            return self
        }
        
        let serializer = Request.imageResponseSerializer(decompressImage:true, cacheImage:true)
        return response(responseSerializer: serializer, completionHandler: completionHandler)
    }
    
    func responseImage(_ completionHandler: (Response<UIImage, NSError>) -> Void) -> Self {
        let serializer = Request.imageResponseSerializer()
        return response(responseSerializer: serializer, completionHandler: completionHandler)
    }
    
    // MARK: Private methods
    // From AFNetworking, as ported to Swift by Martin Conte Mac Donell (Reflejo@gmail.com) on 2/3/15.
    // Copyright (c) 2013-2015 Lyft (http://lyft.com)
    // also here: https://github.com/Alamofire/Alamofire/pull/333
    
    fileprivate class func decompressImage(_ response: HTTPURLResponse, data: NSData) -> UIImage? {
        if data.length == 0 {
            return nil
        }
        
        let dataProvider = CGDataProvider(data: data)
        
        var imageRef: CGImage?
        if response.mimeType == "image/png" {
            imageRef = CGImageCreateWithPNGDataProvider(dataProvider!, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
            
        } else if response.mimeType == "image/jpeg" {
            imageRef = CGImageCreateWithJPEGDataProvider(dataProvider!, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
            
            // CGImageCreateWithJPEGDataProvider does not properly handle CMKY, so if so,
            // fall back to AFImageWithDataAtScale
            if imageRef != nil {
                let imageColorSpace = imageRef!.colorSpace
                let imageColorSpaceModel = imageColorSpace!.model
                switch (imageColorSpaceModel) {
                case .CGColorSpaceModel.cmyk:
                    imageRef = nil
                default:
                    break
                }
            }
        }
        
        let scale = UIScreen.main.scale
        let image = UIImage(data: data as Data, scale: scale)
        if imageRef == nil || image == nil {
            if image == nil || image?.images != nil {
                return image
            }
            
            imageRef = image!.cgImage!.copy()
            if imageRef == nil {
                return nil
            }
        }
        
        let width = imageRef!.width
        let height = imageRef!.height
        let bitsPerComponent = imageRef!.bitsPerComponent
        
        if width * height > 1024 * 1024 || bitsPerComponent > 8 {
            return image
        }
        
        let bytesPerRow = imageRef!.bytesPerRow
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorSpaceModel = colorSpace.model
        let alphaInfo = imageRef!.alphaInfo
        var bitmapInfo:UInt32 = imageRef!.bitmapInfo.rawValue
        if colorSpaceModel == .CGColorSpaceModel.rgb {
            if alphaInfo == .none {
                bitmapInfo &= ~CGBitmapInfo.alphaInfoMask.rawValue
                bitmapInfo |= CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue).rawValue
            } else if (!(alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast)) {
                bitmapInfo &= ~CGBitmapInfo.alphaInfoMask.rawValue
                bitmapInfo |= CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue).rawValue
            }
        }
        
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow,
            space: colorSpace, bitmapInfo: bitmapInfo)
        if context == nil {
            return image
        }
        
        let drawRect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        CGContextDrawImage(context, drawRect, imageRef)
        let inflatedImageRef = context!.makeImage()
        return UIImage(CGImage: inflatedImageRef!, scale: scale, orientation: image!.imageOrientation)
    }
}
