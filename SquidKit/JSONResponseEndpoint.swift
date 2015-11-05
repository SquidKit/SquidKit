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
            .responseJSON(options: self.jsonReadingOptions, completionHandler:{ [weak self] response in
                if let strongSelf = self {
                    switch (response.result) {
                        case .Success(let value):
                            if let jsonDictionary = value as? [String: AnyObject] {
                                strongSelf.connectResponse(jsonDictionary, responseStatus: .OK, completionHandler: completionHandler)
                            }
                            else if let jsonArray = value as? [AnyObject] {
                                strongSelf.connectResponse(jsonArray, responseStatus: .OK, completionHandler:completionHandler)
                            }
                            else {
                                strongSelf.connectResponse(nil, responseStatus: .ResponseFormatError, completionHandler:completionHandler)
                            }
                        case .Failure(let error):
                            strongSelf.connectResponse(nil, responseStatus: strongSelf.formatError(response.response, error:error), completionHandler:completionHandler)
                    }
                }
        })
        
        self.logRequest(encoding, headers: defaultHeaders)
    }
    
    func connectResponse(responseData:AnyObject?, responseStatus:ResponseStatus, completionHandler: (AnyObject?, ResponseStatus) -> Void) {
        self.logResponse(responseData, responseStatus: responseStatus)
        
        completionHandler(responseData, responseStatus)
    }
    
    //OVERRIDE
    public var jsonReadingOptions:NSJSONReadingOptions {
        get {
            return .AllowFragments
        }
    }
}


// MARK: Logging
extension JSONResponseEndpoint {
    
    func logRequest(encoding:ParameterEncoding, headers:[NSObject : AnyObject]?) {
        switch self.requestLogging {
        case .Verbose:
            if let prettyLogger = logger as? VariadicLoggable {
                prettyLogger.log(   "===============================", "\n",
                    "SquidKit Network Request", "\n",
                    "===============================", "\n",
                    "Request = ", self.request?.description, "\n",
                    "Encoding = ", encoding, "\n",
                    "HTTP headers: ", headers, "\n",
                    "===============================", "\n")
            }
            else {
                logger?.log("\(self.request?.description)" + "\n" + "Encoding = " + "\(encoding)" + "\n" + "HTTP headers: " + "\(headers)")
            }
            
        case .Minimal:
            logger?.log(self.request?.description)
            
        default:
            break
        }
    }
    
    func logResponse(responseData:AnyObject?, responseStatus:ResponseStatus) {
        switch self.responseLogging {
        case .Verbose:
            if let prettyLogger = logger as? VariadicLoggable {
                prettyLogger.log(   "===============================", "\n",
                    "SquidKit Network Response for ", self.request?.description, "\n",
                    "===============================", "\n",
                    "Response Status = ", responseStatus, "\n",
                    "JSON:", "\n",
                    responseData, "\n",
                    "===============================", "\n")
            }
            else {
                logger?.log("Response Status = " + "\(responseStatus)" + "\n" + "\(responseData)")
            }
        case .Minimal:
            logger?.log("Response Status = " + "\(responseStatus)")
        default:
            break
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
