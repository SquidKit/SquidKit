//
//  DismissibleViewController.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/15/14.
//  Copyright (c) 2017 SquidKit. All rights reserved.
//

import UIKit

open class DismissibleViewController: UIViewController {

    @IBAction open func dismissOrPop() {
        if self.parent != nil {
            self.pop()
        }
        else if self.presentingViewController != nil {
            self.dismissModal()
        }
        else {
            self.pop()
        }
    }
    
    fileprivate func pop() {
        if self.navigationController != nil &&
            self.navigationController!.viewControllers[0] as NSObject == self &&
            self.navigationController!.presentingViewController != nil {
                self.navigationController!.presentingViewController!.dismiss(animated: true, completion: nil)
        }
        else if self.navigationController != nil {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    fileprivate func dismissModal() {
        if self.navigationController != nil {
            self.navigationController!.dismiss(animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
