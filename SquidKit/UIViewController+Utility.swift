//
//  UIViewController+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 9/6/18.
//  Copyright © 2018-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    /// how topMost responds if the top view controller is an UIAlertController
    enum TopAlertBehavior {
        case alert          // return the UIAlertController
        case previous       // return the previous view controller in the stack
        case `nil`          // return nil
    }
    
    class func topMost(alertBehavior: TopAlertBehavior = .previous) -> UIViewController? {
        let window = UIApplication.shared.delegate?.window ?? UIApplication.shared.keyWindow
        return topMost(window: window, alertBehavior: alertBehavior)
    }
    
    class func topMost(window: UIWindow?, alertBehavior: TopAlertBehavior = .previous) -> UIViewController? {
        return window?.rootViewController?.top(UIApplication.shared.keyWindow?.rootViewController, alertBehavior: alertBehavior)
    }
        
    func top(_ previous: UIViewController?, alertBehavior: TopAlertBehavior = .previous) -> UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.top(navigationController.topViewController, alertBehavior: alertBehavior)
        }
        else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.top(tabBarController.selectedViewController, alertBehavior: alertBehavior)
        }
        else if let presentedViewController = presentedViewController {
            return presentedViewController.top(presentedViewController, alertBehavior: alertBehavior)
        }
        else if self is UIAlertController {
            switch alertBehavior {
            case .nil:
                return nil
            case .alert:
                return self
            case .previous:
                return previous
            }
        }
        else {
            return self
        }
    }
}

