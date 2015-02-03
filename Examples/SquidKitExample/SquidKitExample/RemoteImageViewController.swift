//
//  RemoteImageViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit
import SquidKit

class RemoteImageViewController: UIViewController {
    
    @IBOutlet weak var imageView:UIImageView?

    override func viewDidLoad() {
        let url = NSURL(string: "http://static1.squarespace.com/static/53f53bcfe4b0a95765d3c5ed/t/53f53dd6e4b08f2d1d7dc8ba/1410483871285/")
        
        let scale = UIScreen.mainScreen().scale
        
        SquidKit.request(.GET, url!).responseImage(Float(scale)) {[unowned self]
            (_, _, image, error) in
            if error == nil && image != nil {
                self.imageView?.image = image;
            }
        }
    }
}
