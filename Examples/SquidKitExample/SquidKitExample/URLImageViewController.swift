//
//  URLImageViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 2/3/15.
//  Copyright (c) 2015 SquidKit. All rights reserved.
//

import UIKit
import SquidKit

class URLImageViewController: UIViewController {

    @IBOutlet var imageView:URLImageView?
    
    let downloader = ImageDownloader()
    
    var urlString = "https://static1.squarespace.com/static/52eea758e4b0fff11bf07129/52eeeda0e4b0fff11bf09db9/52eeee41e4b0b43e3bb4e615/1391390276529/DSC_3729.jpg"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        imageView?.downloadService = downloader
        imageView?.url = URL(string: urlString)
        imageView?.activityIndicatorType = .dark
        imageView?.load()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView?.imageAppearanceType = .fadeIfNotCached(0.5, 0.0, 1.0)
    }
}

class ImageDownloader: URLImageDownloading {
    
    var task: URLSessionDownloadTask?
    
    func download(url: URL, completion: @escaping URLImageDownloadingCompletion) {
        task = URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) in
            guard let locationData = location else {
                completion(nil, nil)
                return
            }
            guard let image = ((try? UIImage(data: Data(contentsOf: locationData))) as UIImage??) else {
                completion(nil, nil)
                return
            }
            completion(image, nil)
        })
        
        task?.resume()
    }
    
    func cancel(url: URL) {
        //
    }
}
