//
//  Alamofire+Image.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit

public extension Request {
    class func imageResponseSerializer(scale:Float?) -> Serializer {
        return { request, response, data in
            if data == nil {
                return (nil, nil)
            }
            
            var imageScale:Float = 1.0
            if let preferredScale = scale {
                imageScale = preferredScale
            }
            
            let image = UIImage(data: data!, scale: CGFloat(imageScale))
            
            return (image, nil)
        }
    }
    
    public func responseImage(scale:Float?, completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
        return response(serializer: Request.imageResponseSerializer(scale), completionHandler: { (request, response, image, error) in
            completionHandler(request, response, image as? UIImage, error)
        })
    }
}
