//
//  ThemedViewController.swift
//  SquidKitExample
//
//  Created by Mike Leavy on 8/24/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit
import SquidKit

class ThemedViewController: UIViewController {

    override func awakeFromNib() {
        ThemeLoader.loadThemesFromResourceFile("ExampleTheme.json")
        ThemeManager.sharedInstance.setDefaultTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
