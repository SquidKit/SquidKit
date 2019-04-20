//
//  NSDictionaryExtension.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright © 2017-2019 Squid Store, LLC. All rights reserved.
//

import Foundation

public extension NSDictionary {
    
    class func dictionaryFromResourceFile(_ fileName:String) -> NSDictionary? {
        
        if let inputStream = InputStream(fileAtPath:String.stringWithPathToResourceFile(fileName)) {
            inputStream.open()
            
            let dictionary = try? JSONSerialization.jsonObject(with: inputStream, options:JSONSerialization.ReadingOptions(rawValue: 0))

            inputStream.close()
            
            return dictionary as? NSDictionary
            
        }
        
        return nil
    }
}
