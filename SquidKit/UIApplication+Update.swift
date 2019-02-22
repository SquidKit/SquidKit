//
//  UIApplication+Update.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/24/18.
//  Copyright © 2018-2019 Squid Store, LLC. All rights reserved.
//

import UIKit

private func parseVersion(_ lhs: AppVersion, rhs: AppVersion) -> Zip2Sequence<[Int], [Int]> {
    
    let lhs = lhs.versionString.split(separator: ".").map { (String($0) as NSString).integerValue }
    let rhs = rhs.versionString.split(separator: ".").map { (String($0) as NSString).integerValue }
    let count = max(lhs.count, rhs.count)
    return zip(
        lhs + Array(repeating: 0, count: count - lhs.count),
        rhs + Array(repeating: 0, count: count - rhs.count))
}

public func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
    
    var result: Bool = true
    for (l, r) in parseVersion(lhs, rhs: rhs) {
        
        if l != r {
            result = false
        }
    }
    return result
}

public func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
    
    for (l, r) in parseVersion(lhs, rhs: rhs) {
        if l < r {
            return true
        }
        else if l > r {
            return false
        }
    }
    return false
}

public struct AppVersion: Comparable {
    
    public static var marketingVersion: AppVersion? {
        guard let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return AppVersion(shortVersion)
    }
    
    public static var version: AppVersion? {
        guard let bundleVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String else {
            return nil
        }
        return AppVersion(bundleVersion)
    }
    
    fileprivate(set) public var versionString: String
    
    public init(_ versionString: String) {
        
        self.versionString = versionString
    }
    
}

extension AppVersion: CustomStringConvertible {
    public var description: String {
        return self.versionString
    }
}


public typealias AppUpdateInfoCompletion = (UIApplication.StoreVersion, URL?, Error?) -> Void
extension UIApplication {
    
    // Enumeration constants for app store version status as compaered to version of currently running app.
    // String parameters are the app store version short string
    public enum StoreVersion: CustomStringConvertible {
        // version on store is newer
        case newer(String)
        // version on store is older
        case older(String)
        // app version and store version are identical
        case identical(String)
        // store version is unknown or could not be determined
        case unknown
        
        public var description: String {
            switch self {
            case .newer(let value):
                return "newer (\(value))"
            case .older(let value):
                return "older (\(value))"
            case .identical(let value):
                return "identical (\(value))"
            case .unknown:
                return "unknown"
            }
        }
    }
    
    private struct AppStoreLookupResult: Decodable {
        var results: [AppStoreLookupInfo]
    }
    
    private struct AppStoreLookupInfo: Decodable {
        var version: String
        var trackViewUrl: String?
    }
    
    public enum AppUpdateVersionError: Error {
        case invalidBundleInfo
        case invalidResponse
    }
    
    private func getAppInfo(completion: @escaping (AppStoreLookupInfo?, Error?) -> Void) -> URLSessionDataTask? {
        guard let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                DispatchQueue.main.async {
                    completion(nil, AppUpdateVersionError.invalidBundleInfo)
                }
                return nil
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error {throw error}
                guard let data = data else {throw AppUpdateVersionError.invalidResponse}
                let result = try JSONDecoder().decode(AppStoreLookupResult.self, from: data)
                guard let info = result.results.first else {throw AppUpdateVersionError.invalidResponse}
                
                completion(info, nil)
            }
            catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    public func checkAppStoreVersion(completion: @escaping AppUpdateInfoCompletion) {
        guard let currentVersion = AppVersion.marketingVersion else {
            completion(.unknown, nil, nil)
            return
        }
        let _ = getAppInfo { [weak self] (info, error) in
            guard error == nil else {
                self?.handleCompletion(version: .unknown, url: nil, error: error, completion: completion)
                return
            }
            guard let version = info?.version else {
                self?.handleCompletion(version: .unknown, url: nil, error: nil, completion: completion)
                return
            }
            var storeURL: URL?
            if let trackURL = info?.trackViewUrl {
                var components = URLComponents(string: trackURL)
                // set the "load store" and "media type" parameters
                let loadStoreItem = URLQueryItem(name: "ls", value: "1")
                let mediaTypeItem = URLQueryItem(name: "mt", value: "8")
                components?.queryItems = [loadStoreItem, mediaTypeItem]
                storeURL = components?.url
            }
            let appStoreVersion = AppVersion(version)
            var status = StoreVersion.unknown
            if appStoreVersion == currentVersion {
                status = .identical(version)
            }
            else if appStoreVersion > currentVersion {
                status = .newer(version)
            }
            else if appStoreVersion < currentVersion {
                status = .older(version)
            }
            self?.handleCompletion(version: status, url: storeURL, error: error, completion: completion)
        }
    }
    
    private func handleCompletion(version: StoreVersion, url: URL?, error: Error?, completion: @escaping AppUpdateInfoCompletion) {
        DispatchQueue.main.async {
            completion(version, url, error)
        }
    }
}
