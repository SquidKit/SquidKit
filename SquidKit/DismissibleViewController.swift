//
//  DismissibleViewController.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/15/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

public class DismissibleViewController: UIViewController {

    @IBAction public func dismissOrPop() {
        if self.parentViewController != nil {
            self.pop()
        }
        else if self.presentingViewController != nil {
            self.dismissModal()
        }
        else {
            self.pop()
        }
    }
    
    private func pop() {
        if self.navigationController != nil &&
            self.navigationController.viewControllers[0] as NSObject == self &&
            self.navigationController.presentingViewController != nil {
                self.navigationController.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        else if self.navigationController != nil {
            self.navigationController.popViewControllerAnimated(true)
        }
    }
    
    private func dismissModal() {
        if self.navigationController != nil {
            self.navigationController.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
