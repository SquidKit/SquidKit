//
//  JSONEndpoint.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/24/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import UIKit

public class JSONResponseEndpoint: Endpoint {
    
    var manager:Manager?
   
    public func connect(completionHandler: (AnyObject?, ResponseStatus) -> Void) {
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
        
        var defaultHeaders = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        if let additionalHeaders = self.additionalHeaders() {
            for (headerName, headerValue) in additionalHeaders {
                defaultHeaders[headerName] = headerValue
            }
        }
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        
        self.manager = Manager(configuration: configuration)
        
        
        Log.message(self.url())
        
        self.manager!.request(method, self.url(), parameters: params, encoding: encoding)
            .responseJSON { (request, response, data, error) -> Void in
                if (error != nil) {
                    completionHandler(nil, self.formatError(response, error:error))
                }
                else if let jsonDictionary = data as? [String: AnyObject] {
                    completionHandler(jsonDictionary, .OK)
                }
                else if let jsonArray = data as? [AnyObject] {
                    completionHandler(jsonArray, .OK)
                }
                else {
                    completionHandler(nil, .ResponseFormatError)
                }
        }
    }
    
}
