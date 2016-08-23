//
//  String+File.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/16/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

public extension String {
    
    public static func stringWithPathToResourceDirectory() -> String {
        return Bundle.main.resourcePath!
    }
    
    public static func stringWithPathToResourceFile(_ fileName:String) -> String {
        let path = String.stringWithPathToResourceDirectory()
        var url = URL(fileURLWithPath: path)
        url = url.appendingPathComponent(fileName)
        return url.path
    }
    
    public static func stringWithContentsOfResourceFile(_ fileName:String) -> String? {
        let filePath = String.stringWithPathToResourceFile(fileName)
        if let data = FileManager.default.contents(atPath: filePath) {
            return NSString(data:data, encoding:String.Encoding.utf8.rawValue) as? String
        }
        
        return nil
    }
    
    public static func stringWithPathToDocumentsFile(_ fileName:String) -> String? {
        if let path = String.pathToDocumentsDirectory() {
            var url = URL(fileURLWithPath: path)
            url = url.appendingPathComponent(fileName)
            return url.path
        }
        
        return nil
    }
    
    public static func stringWithContentsOfDocumentsFile(_ fileName:String) -> String? {
        if let filePath = String.stringWithPathToDocumentsFile(fileName) {
            if let data = FileManager.default.contents(atPath: filePath) {
                return NSString(data:data, encoding:String.Encoding.utf8.rawValue) as? String
            }
        }
        
        return nil
    }
    
    public static func pathToApplicationBundle() -> String {
        return Bundle.main.bundlePath
    }
    
    public static func pathToDocumentsDirectory() -> String? {
        
        return String.pathToUserDirectory(FileManager.SearchPathDirectory.documentDirectory)
    }
    
    public static func pathToCacheDirectory() -> String? {
        
        return String.pathToUserDirectory(FileManager.SearchPathDirectory.cachesDirectory)
    }
    
    public static func pathToUserDirectory(_ directory: FileManager.SearchPathDirectory) -> String? {
        
        if let directories:[String] = NSSearchPathForDirectoriesInDomains(directory, FileManager.SearchPathDomainMask.userDomainMask, true) {
            return directories.last!
        }
        return nil
    }
}
