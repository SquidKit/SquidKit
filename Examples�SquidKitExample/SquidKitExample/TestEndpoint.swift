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
        return "https"
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

class NHTSATestEndpoint: JSONResponseEndpoint {
    
    override var serverTrustPolicy:[String: ServerTrustPolicy] {
        get {
            return ["api.nal.usda.gov": .PerformDefaultEvaluation(validateHost:false)]
        }
    }
    
    override func hostProtocol() -> String {
        return "https"
    }
    
    override func host() -> String {
        return "api.nal.usda.gov"
    }
    
    override func path() -> String {
        return "ndb/list"
    }
    
    override func params() -> ([String: AnyObject]?, SquidKit.Method) {
        return (["format":"json", "lt":"f", "sort": "n", "api_key":"DEMO_KEY"], .GET)
    }

}

