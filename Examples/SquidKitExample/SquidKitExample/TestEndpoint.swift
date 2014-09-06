//
//  TestEndpoint.swift
//  SquidKitNetworkingExample
//
//  Created by Mike Leavy on 8/24/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation
import SquidKit

class TestEndpoint: JSONResponseEndpoint {
    
    override func hostProtocol() -> String {
        return "http"
    }
    
    override func host() -> String {
        return "httpbin.org"
    }
    
    override func path() -> String {
        return "get"
    }
        
    override func params() -> ([String: AnyObject]?, SquidKit.Method) {
        return (["foo": "bar"], .GET)
    }
   
}

class RDCTestEndpoint: JSONResponseEndpoint {
    
    override func hostProtocol() -> String {
        return "http"
    }
    
    override func host() -> String {
        return "mapi.move.com"
    }
    
    override func path() -> String {
        return "appcontrol/v1/version/"
    }
    
    override func params() -> ([String: AnyObject]?, SquidKit.Method) {
        return (nil, .GET)
    }
    
}

