//
//  URLImageView.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit

open class URLImageView: UIImageView {
    
    public enum URLImageViewActivityIndicatorType {
        case none
        case dark
        case light
        case lightLarge
    }
    
    public enum URLImageViewImageAppearanceType {
        case none
        case fade(TimeInterval, Float, Float)
        case fadeIfNotCached(TimeInterval, Float, Float)
    }
    
    open var activityIndicatorType:URLImageViewActivityIndicatorType = .none
    open var imageAppearanceType:URLImageViewImageAppearanceType = .none
    
    open var urlString:String? {
        didSet {
            cancel()
        }
    }
    
    fileprivate var activityView:UIActivityIndicatorView?
    
    fileprivate var activityIndicatorStyle:UIActivityIndicatorViewStyle {
        switch self.activityIndicatorType {
        case .light:
            return .white
        case .lightLarge:
            return .whiteLarge
        case .dark:
            return .gray
        default:
            return .gray
        }
    }
    
    fileprivate var imageRequest:Request?
    
    deinit {
        cancel()
    }
    
    open func load() {
        cancel()
        if let urlString = self.urlString {
            
            let url = URL(string: urlString)
            
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
    
    fileprivate func animateFade(_ image:UIImage?, duration:TimeInterval, beginAlpha:Float, endAlpha:Float) {
        self.alpha = CGFloat(beginAlpha)
        self.image = image
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        self.alpha = CGFloat(endAlpha)
        UIView.commitAnimations()
    }
    
    open func cancel() {
        if let activeRequest = self.imageRequest {
            activeRequest.cancel()
        }
        self.stopActivity()
    }
    
    fileprivate func startActivity() {
        if self.activityIndicatorType != .none {
            if self.activityView == nil {
                self.activityView = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorStyle)
                self.activityView?.centerInView(self)
                self.addSubview(self.activityView!)
            }
            
            self.activityView?.startAnimating()
        }
    }
    
    fileprivate func stopActivity() {
        if self.activityView != nil {
            self.activityView?.stopAnimating()
            self.activityView?.removeFromSuperview()
            self.activityView = nil
        }
    }

}
