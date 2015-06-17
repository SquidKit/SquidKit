//
//  Endpoint.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/24/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public class Endpoint {
    
    public enum ResponseStatus {
        case OK
        case HTTPError(Int, String?)
        case NotConnectedError
        case HostConnectionError
        case ResourceUnavailableError
        case ResponseFormatError
        case UnknownError(NSError?)
    }
    
    var request:Request?
    
    public init() {
        
    }
    
    // Return protocol - typically http or https, with or without "://"
    public func hostProtocol() -> String {
        return "http://"
    }
    
    // OVERRIDE: return host, e.g. "www.somehost.com"
    public func host() -> String {
        return ""
    }
    
    // OVERRIDE: return path, e.g. "resource/search"
    public func path() -> String {
        return ""
    }
    
    // OVERRIDE: retrun either the body or URL params, along with the http method (i.e. .GET, .POST, etc)
    public func params() -> ([String: AnyObject]?, Method) {
        return (nil, .GET)
    }
    
    // OVERRIDE: return desired parameter encoding; default will be URL for GETs and JSON for POSTs
    public func encoding() -> ParameterEncoding? {
        return nil
    }
    
    // OVERRIDE: return additional HTTP headers
    public func additionalHeaders() -> [NSObject : AnyObject]? {
        return nil
    }
    
    // OVERRIDE: return basic auth username / password
    public func basicAuthPair() -> (name:String?, password:String?) {
        return (nil, nil)
    }
    
    public func cancel() {
        self.request?.cancel()
    }
    
    public func url() -> String {
        var aProtocol = self.hostProtocol()
        var aHost = self.host()
        
        if let mappedPair = EndpointMapper.mappedPairForCanonicalHost(aHost) {
            if mappedPair.hostProtocol != nil {
                aProtocol = mappedPair.hostProtocol!
            }
            if mappedPair.host != nil {
                aHost = mappedPair.host!
            }
        }
        
        var url = aProtocol
        
        if !url.hasSuffix("://") {
            url += "://"
        }
        
        url = url + aHost + "/" + self.path()
        return url
    }
    
    func formatError(response:NSHTTPURLResponse?, error:NSError?) -> ResponseStatus {
        if (response != nil) {
            var errorMessage:String?
            if let message:AnyObject = response!.allHeaderFields["Error"] {
                errorMessage = message as? String
            }
            else if let message:AnyObject = response!.allHeaderFields["Status"] {
                errorMessage = message as? String
            }
            let statusCode = response!.statusCode
            
            return .HTTPError(statusCode, errorMessage)
        }
        else if (error != nil) {
            var responseStatus:ResponseStatus = .UnknownError(error)
            switch error!.code {
            case NSURLErrorNotConnectedToInternet:
                responseStatus = .NotConnectedError
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                responseStatus = .HostConnectionError
            case NSURLErrorResourceUnavailable:
                responseStatus = .ResourceUnavailableError
            default:
                break
            }
            
            return responseStatus
        }
        
        return .UnknownError(error)
    }
    
}

