//
//  DateFormatter+Utility.swift
//  SquidKit
//
//  Created by Mike Leavy on 9/15/18.
//  Copyright © 2018-2019 Squid Store, LLC. All rights reserved.
//

import Foundation

public extension DateFormatter {
    convenience init(format: String) {
        self.init()
        dateFormat = format
        formatterBehavior = .default
    }
}
