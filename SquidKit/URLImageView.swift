//
//  URLImageView.swift
//  SquidKit
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit

public typealias ImageDownloadCompletion = (UIImage?,Bool?) -> Void
public protocol ImageDownloadService {
    func download(url: URL, completion:@escaping ImageDownloadCompletion)
    func cancel(url: URL)
}

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
    
    
    fileprivate var activityView:UIActivityIndicatorView?
    
    fileprivate var activityIndicatorStyle:UIActivityIndicatorViewStyle {
        switch activityIndicatorType {
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
    
    open var url: URL? {
        willSet {
            cancel()
        }
    }
    
    open var downloadService:ImageDownloadService?
    
    deinit {
        cancel()
    }
    
    open func load() {
        cancel()
        guard  let imageURL = url else {return}
        guard let service = downloadService else {return}
        
        startActivity()
        
        service.download(url: imageURL, completion: { [weak self] (image, wasCached) in
            self?.stopActivity()
            let cached = wasCached ?? false
            guard let strongSelf = self else {return}
            if let resultImage = image {
                switch strongSelf.imageAppearanceType {
                case .fade(let duration, let beginAlpha, let endAlpha):
                    strongSelf.animateFade(resultImage, duration: duration, beginAlpha: beginAlpha, endAlpha: endAlpha)
                    
                case .fadeIfNotCached(let duration, let beginAlpha, let endAlpha):
                    strongSelf.animateFade(resultImage, duration: cached ? 0 : duration, beginAlpha: beginAlpha, endAlpha: endAlpha)
                    
                default:
                    strongSelf.image = resultImage
                    strongSelf.setNeedsDisplay()
                }
            }
        })
    }
    
    fileprivate func animateFade(_ image:UIImage?, duration:TimeInterval, beginAlpha:Float, endAlpha:Float) {
        alpha = CGFloat(beginAlpha)
        self.image = image
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        alpha = CGFloat(endAlpha)
        UIView.commitAnimations()
    }
    
    open func cancel() {
        if let imageURL = url {
            downloadService?.cancel(url: imageURL)
        }
        stopActivity()
    }
    
    fileprivate func startActivity() {
        if activityIndicatorType != .none {
            if activityView == nil {
                activityView = UIActivityIndicatorView(activityIndicatorStyle: activityIndicatorStyle)
                activityView?.centerInView(self)
                addSubview(activityView!)
            }
            
            activityView?.startAnimating()
        }
    }
    
    fileprivate func stopActivity() {
        if activityView != nil {
            activityView?.stopAnimating()
            activityView?.removeFromSuperview()
            activityView = nil
        }
    }

}
