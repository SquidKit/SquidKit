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
        let url = URL(string: "https://static1.squarespace.com/static/52eea758e4b0fff11bf07129/52eeeda0e4b0fff11bf09db9/52eeee57e4b0cfc36d9583d1/1391390297091/DSCF0984.jpg")
                        
        SquidKit.request(.GET, url!).responseImageCacheable {[unowned self] response in
            switch response.result {
            case .Success(let image):
                self.imageView?.image = image
            default:
                break
            }
        }
        
    }
}
