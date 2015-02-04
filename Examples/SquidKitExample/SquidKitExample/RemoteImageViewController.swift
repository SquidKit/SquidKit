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
        let url = NSURL(string: "http://static1.squarespace.com/static/52eea758e4b0fff11bf07129/52eeeda0e4b0fff11bf09db9/52eeee57e4b0cfc36d9583d1/1391390297091/DSCF0984.jpg")
        
        let scale = UIScreen.mainScreen().scale
                
        SquidKit.request(.GET, url!).responseImageCacheable {[unowned self]
            (_, _, image:UIImage?) -> Void in
            if image != nil {
                self.imageView?.image = image
            }
        }
        
    }
}
