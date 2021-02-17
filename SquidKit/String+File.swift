//
//  String+File.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright © 2014-2019 Squid Store, LLC. All rights reserved.
//

import Foundation

public extension String {
    
    static func stringWithPathToResourceDirectory() -> String {
        return Bundle.main.resourcePath!
    }
    
    static func stringWithPathToResourceFile(_ fileName:String, bundle: Bundle = Bundle.main) -> String {
        let path = bundle.resourcePath!
        var url = URL(fileURLWithPath: path)
        url = url.appendingPathComponent(fileName)
        return url.path
    }
    
    static func stringWithContentsOfResourceFile(_ fileName:String) -> String? {
        let filePath = String.stringWithPathToResourceFile(fileName)
        if let data = FileManager.default.contents(atPath: filePath) {
            return NSString(data:data, encoding:String.Encoding.utf8.rawValue) as String?
        }
        
        return nil
    }
    
    static func stringWithPathToDocumentsFile(_ fileName:String) -> String? {
        if let path = String.pathToDocumentsDirectory() {
            var url = URL(fileURLWithPath: path)
            url = url.appendingPathComponent(fileName)
            return url.path
        }
        
        return nil
    }
    
    static func stringWithContentsOfDocumentsFile(_ fileName:String) -> String? {
        if let filePath = String.stringWithPathToDocumentsFile(fileName) {
            if let data = FileManager.default.contents(atPath: filePath) {
                return NSString(data:data, encoding:String.Encoding.utf8.rawValue) as String?
            }
        }
        
        return nil
    }
    
    static func pathToApplicationBundle() -> String {
        return Bundle.main.bundlePath
    }
    
    static func pathToDocumentsDirectory() -> String? {
        
        return String.pathToUserDirectory(FileManager.SearchPathDirectory.documentDirectory)
    }
    
    static func pathToCacheDirectory() -> String? {
        
        return String.pathToUserDirectory(FileManager.SearchPathDirectory.cachesDirectory)
    }
    
    static func pathToUserDirectory(_ directory: FileManager.SearchPathDirectory) -> String? {
        
        let directories:[String] = NSSearchPathForDirectoriesInDomains(directory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if directories.count > 0 {
            return directories.last!
        }

            return nil
    }
}
