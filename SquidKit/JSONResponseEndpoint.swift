//
//  JSONEndpoint.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/24/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

public class JSONResponseEndpoint: Endpoint {
   
    public func connect(completionHandler: ([String: AnyObject]?, ResponseStatus) -> Void) {
        let (params, method) = self.params()
        var encoding:ParameterEncoding = .URL
        if let specifiedEncoding = self.encoding() {
            encoding = specifiedEncoding
        }
        else {
            switch method {
            case .POST:
               encoding = .JSON
            default:
                break
            }
        }
        
        Log.message(self.url())
        
        request(method, self.url(), parameters: params, encoding: encoding)
            .responseJSON { (request, response, data, error) -> Void in
                if (error != nil) {
                    completionHandler(nil, self.formatError(response, error:error))
                }
                else if let JSON = data as? [String: AnyObject] {
                    completionHandler(JSON, .OK)
                }
                else {
                    completionHandler(nil, .ResponseFormatError)
                }
        }
    }
    
}
