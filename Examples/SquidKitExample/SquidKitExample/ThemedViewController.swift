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
    
    @IBOutlet weak var label:ThemeLabel?

    override func awakeFromNib() {
        let _ = ThemeLoader.loadThemesFromResourceFile("ExampleTheme.json")
        ThemeManager.sharedInstance.setDefaultTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        label!.text = Theme.activeTheme()?.stringForKey("myThemeText")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ThemeManager : ThemeManagerLoggable {
    public func log<T>(_ output:@autoclosure () -> T?) {
        Log.print(output())
    }
}
