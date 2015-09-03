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
        
        
        var serverTrustPolicyManager:ServerTrustPolicyManager?
        if self.serverTrustPolicy.count > 0 {
            serverTrustPolicyManager = ServerTrustPolicyManager(policies: self.serverTrustPolicy)
        }
        self.manager = Manager(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager)
        
        
        let (user, password) = self.basicAuthPair()
        
        
        self.request = self.manager!.request(method, self.url(), parameters: params, encoding: encoding)
            .shouldAuthenticate(user: user, password: password)
            .validate()
            .responseJSON(options: self.jsonReadingOptions, completionHandler:{ (request, response, result) -> Void in
                switch (result) {
                    case .Success(let value):
                        if let jsonDictionary = value as? [String: AnyObject] {
                            completionHandler(jsonDictionary, .OK)
                        }
                        else if let jsonArray = value as? [AnyObject] {
                            completionHandler(jsonArray, .OK)
                        }
                        else {
                            completionHandler(nil, .ResponseFormatError)
                        }
                    case .Failure(_, let error):
                        completionHandler(nil, self.formatError(response, error:error as NSError))
                }
        })
        
        Log.message(self.request?.description)
    }
    
    //OVERRIDE
    public var jsonReadingOptions:NSJSONReadingOptions {
        get {
            return .AllowFragments
        }
    }
    
}

extension Request {
    func shouldAuthenticate(user user: String?, password: String?) -> Self {
        if let haveUser = user, havePassword = password {
            return self.authenticate(user: haveUser, password: havePassword)
        }
        return self
    }
}
