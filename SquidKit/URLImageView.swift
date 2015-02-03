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
    
    @IBInspectable public var activityIndicatorType:URLImageViewActivityIndicatorType = .None
    
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
            
            let scale = UIScreen.mainScreen().scale
            
            let url = NSURL(string: urlString)
            
            startActivity()
            
            self.imageRequest = request(.GET, url!).responseImage(Float(scale)) {[unowned self]
                (_, _, image, error) in
                self.stopActivity()
                if error == nil && image != nil {
                    self.image = image;
                    self.setNeedsDisplay()
                }
            }
        }
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
