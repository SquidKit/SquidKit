//
//  URLImageView.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit

public class URLImageView: UIImageView {
    
    public enum URLImageViewActivityIndicatorType {
        case None
        case Dark
        case Light
        case LightLarge
    }
    
    public enum URLImageViewImageAppearanceType {
        case None
        case Fade(NSTimeInterval, Float, Float)
        case FadeIfNotCached(NSTimeInterval, Float, Float)
    }
    
    public var activityIndicatorType:URLImageViewActivityIndicatorType = .None
    public var imageAppearanceType:URLImageViewImageAppearanceType = .None
    
    public var urlString:String? {
        didSet {
            cancel()
        }
    }
    
    private var activityView:UIActivityIndicatorView?
    
    private var activityIndicatorStyle:UIActivityIndicatorViewStyle {
        switch self.activityIndicatorType {
        case .Light:
            return .White
        case .LightLarge:
            return .WhiteLarge
        case .Dark:
            return .Gray
        default:
            return .Gray
        }
    }
    
    private var imageRequest:Request?
    
    public func load() {
        cancel()
        if let urlString = self.urlString {
            
            let url = NSURL(string: urlString)
            
            startActivity()
            
            self.imageRequest = request(.GET, url!)
                .responseImageCacheable {[unowned self] response in
                
                self.stopActivity()
                    
                    switch response.result {
                    case .Success(let image):
                        switch self.imageAppearanceType {
                        case .Fade(let duration, let beginAlpha, let endAlpha):
                            self.animateFade(image, duration: duration, beginAlpha: beginAlpha, endAlpha: endAlpha)
                            
                        case .FadeIfNotCached(let duration, let beginAlpha, let endAlpha):
                            self.animateFade(image, duration: response.response == nil ? 0 : duration, beginAlpha: beginAlpha, endAlpha: endAlpha)
                            
                        default:
                            self.image = image
                            self.setNeedsDisplay()
                        }
                    default:
                        break;
                    }
            }
        }
    }
    
    private func animateFade(image:UIImage?, duration:NSTimeInterval, beginAlpha:Float, endAlpha:Float) {
        self.alpha = CGFloat(beginAlpha)
        self.image = image
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        self.alpha = CGFloat(endAlpha)
        UIView.commitAnimations()
    }
    
    public func cancel() {
        if let activeRequest = self.imageRequest {
            activeRequest.cancel()
        }
        self.stopActivity()
    }
    
    private func startActivity() {
        if self.activityIndicatorType != .None {
            if self.activityView == nil {
                self.activityView = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorStyle)
                self.activityView?.centerInView(self)
                self.addSubview(self.activityView!)
            }
            
            self.activityView?.startAnimating()
        }
    }
    
    private func stopActivity() {
        if self.activityView != nil {
            self.activityView?.stopAnimating()
            self.activityView?.removeFromSuperview()
            self.activityView = nil
        }
    }

}
