//
//  TestEndpoint.swift
//  SquidKitExample
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

class TaxeeTestEndpoint: JSONResponseEndpoint {
    
    override func hostProtocol() -> String {
        return "http"
    }
    
    override func host() -> String {
        return "taxee.io"
    }
    
    override func path() -> String {
        return "api/v1/federal/2014"
    }
    
    override func params() -> ([String: AnyObject]?, SquidKit.Method) {
        return (nil, .GET)
    }
    
}

class TaxeeTestEndpoint2: JSONResponseEndpoint {
    
    override func hostProtocol() -> String {
        return "http"
    }
    
    override func host() -> String {
        return "taxee.io"
    }
    
    override func path() -> String {
        return "api/v1/calculate/2014"
    }
    
    override func params() -> ([String: AnyObject]?, SquidKit.Method) {
        return (["pay_rate": 100000, "filing_status": "single"], .POST)
    }
    
    override func encoding() -> ParameterEncoding? {
        return .URL
    }
    
}

