//
//  NSDictionaryExtension.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public extension NSDictionary {
    
    public class func dictionaryFromResourceFile(fileName:String) -> NSDictionary? {
        
        if let inputStream = NSInputStream(fileAtPath:String.stringWithPathToResourceFile(fileName)) {
            inputStream.open()
            
            let dictionary = try? NSJSONSerialization.JSONObjectWithStream(inputStream, options:NSJSONReadingOptions(rawValue: 0))

            inputStream.close()
            
            return dictionary as? NSDictionary
            
        }
        
        return nil
    }
}