//
//  EndpointMap.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/27/14.
//  Copyright © 2014-2019 Squid Store, LLC. All rights reserved.
//

import Foundation

private let _EndpointMapperSharedInstance = EndpointMapper()

public protocol HostMapCacheStorable {
    func setEntry(_ entry:[String: AnyObject], key:String)
    func getEntry(_ key:String) -> [String: AnyObject]?
    func remove(_ key:String)
}

public struct ProtocolHostPair: CustomStringConvertible, CustomDebugStringConvertible {
    public var hostProtocol:String?
    public var host:String?
    
    public init(_ hostProtocol:String?, _ host:String?) {
        self.hostProtocol = hostProtocol
        self.host = host
    }
    
    public var description: String {
        return "ProtocolHostPair: protocol = \(String(describing: hostProtocol)); host = \(String(describing: host))"
    }

    public var debugDescription: String {
        return self.description
    }

}

func == (left:ProtocolHostPair, right:ProtocolHostPair) -> Bool {
    return left.host == right.host && left.hostProtocol == right.hostProtocol
}

open class EndpointMapper {
    
    fileprivate var mappedHosts = [String: ProtocolHostPair]()
    
    fileprivate init() {
        
    }
    
    open class var sharedInstance: EndpointMapper {
        return _EndpointMapperSharedInstance
    }
    
    open class func addProtocolHostMappedPair(_ mappedPair:ProtocolHostPair, canonicalHost:String) {
        EndpointMapper.sharedInstance.mappedHosts[canonicalHost] = mappedPair
    }
    
    open class func removeProtocolHostMappedPair(_ canonicalHost:String) {
        EndpointMapper.sharedInstance.mappedHosts[canonicalHost] = nil
    }
    
    open class func mappedPairForCanonicalHost(_ canonicalHost:String) -> (ProtocolHostPair?) {
        return EndpointMapper.sharedInstance.mappedHosts[canonicalHost]
    }
    
}

open class HostMap {
    
    public static let editableHostAlphanumericPlaceholderExpression = "<@>"
    public static let editableHostNnumericPlaceholderExpression = "<#>"
    public let canonicalProtocolHost:ProtocolHostPair
    
    open var releaseKey = ""
    open var prereleaseKey = ""
    open var mappedPairs = [String: ProtocolHostPair]()
    open var sortedKeys = [String]()
    open var editableKeys = [String]()
    open var numericEditableKeys = [String]()

    open var canonicalHost:String {
        if let host = canonicalProtocolHost.host {
            return host
        }
        return ""
    }
    
    public init(canonicalProtocolHostPair:ProtocolHostPair) {
        self.canonicalProtocolHost = canonicalProtocolHostPair
    }
    
    open func pairWithKey(_ key:String) -> ProtocolHostPair? {
        return mappedPairs[key]
    }

    open func isEditable(_ key:String) -> Bool {
        return editableKeys.contains(key)
    }
    
    open func isNumericallyEditable(_ key:String) -> Bool {
        return numericEditableKeys.contains(key)
    }
}

open class HostMapManager {
    open var hostMaps = [HostMap]()

    fileprivate var hostMapCache:HostMapCache!
    
    required public init(cacheStore:HostMapCacheStorable?) {
        self.hostMapCache = HostMapCache(cacheStore: cacheStore)
    }
    

    open func loadConfigurationMapFromResourceFile(_ fileName:String, bundle: Bundle = Bundle.main) -> Bool {
        let result = HostConfigurationsLoader.loadConfigurationsFromResourceFile(fileName, bundle: bundle, manager: self)
        self.restoreFromCache()
        return result
    }

    open func setReleaseConfigurations() {
        for hostMap in self.hostMaps {
            if let releasePair = hostMap.pairWithKey(hostMap.releaseKey) {
                EndpointMapper.addProtocolHostMappedPair(releasePair, canonicalHost: hostMap.canonicalHost)
            }
        }
    }

    open func setPrereleaseConfigurations() {
        for hostMap in self.hostMaps {
            if let preReleasePair = hostMap.pairWithKey(hostMap.prereleaseKey) {
                EndpointMapper.addProtocolHostMappedPair(preReleasePair, canonicalHost: hostMap.canonicalHost)
            }
        }
    }

    open func setConfigurationForCanonicalHost(_ configurationKey:String, mappedHost:String?, canonicalHost:String, withCaching:Bool = true) {
        for hostMap in self.hostMaps {
            if hostMap.canonicalProtocolHost.host == canonicalHost {
                var runtimePair = hostMap.pairWithKey(configurationKey)
                if runtimePair != nil {
                    if mappedHost != nil {
                        runtimePair!.host = mappedHost
                        hostMap.mappedPairs[configurationKey] = runtimePair
                    }
                    let empty:Bool = (runtimePair!.host == nil || runtimePair!.host!.isEmpty)
                    if !empty {
                        EndpointMapper.addProtocolHostMappedPair(runtimePair!, canonicalHost: canonicalHost)
                    }
                    else {
                        EndpointMapper.removeProtocolHostMappedPair(canonicalHost)
                    }
                    if withCaching {
                        if !empty {
                            self.hostMapCache.cacheKeyAndHost(configurationKey, mappedHost:runtimePair!.host!, forCanonicalHost: canonicalHost)
                        }
                        else {
                            self.hostMapCache.removeCachedKeyForCanonicalHost(canonicalHost)
                        }
                    }
                }
                break
            }
        }
    }


    fileprivate func restoreFromCache() {
        for hostMap in self.hostMaps {
            if let (key, host) = self.hostMapCache.retreiveCachedKeyAndHostForCanonicalHost(hostMap.canonicalHost) {
                self.setConfigurationForCanonicalHost(key, mappedHost:host, canonicalHost: hostMap.canonicalHost, withCaching: false)
            }
        }
    }

    fileprivate class HostConfigurationsLoader {
    
        fileprivate class func loadConfigurationsFromResourceFile(_ fileName: String, bundle: Bundle, manager:HostMapManager) -> Bool {
            var result = false
            
            if let hostDictionary = NSDictionary.dictionaryFromResourceFile(fileName, bundle: bundle) {
                result = true
                
                if let configurations:NSArray = hostDictionary.object(forKey: "configurations") as? NSArray {
                    
                    for configuration in configurations {
                        HostConfigurationsLoader.handleConfiguration(configuration as AnyObject, manager: manager)
                    }
                    
                }
                
            }
            
            return result
        }

        fileprivate class func handleConfiguration(_ configuration:AnyObject, manager:HostMapManager) {
            if let config:[String: AnyObject] = configuration as? [String: AnyObject] {
                let canonicalHost:String? = config[HostConfigurationKey.CanonicalHost.rawValue] as? String
                let canonicalProtocol:String? = config[HostConfigurationKey.CanonicalProtocol.rawValue] as? String
                let releaseKey:String? = config[HostConfigurationKey.ReleaseKey.rawValue] as? String
                let prereleaseKey:String? = config[HostConfigurationKey.PrereleaseKey.rawValue] as? String

                if canonicalHost != nil && canonicalProtocol != nil {
                    let hostMap = HostMap(canonicalProtocolHostPair:ProtocolHostPair(canonicalProtocol, canonicalHost))
                    
                    if let release = releaseKey {
                        hostMap.releaseKey = release
                    }
                    if let prerelease = prereleaseKey {
                        hostMap.prereleaseKey = prerelease
                    }

                    if let hostsArray:[[String: String]] = config[HostConfigurationKey.Hosts.rawValue] as? [[String: String]] {
                        for host in hostsArray {
                            let aKey:String? = host[.HostsKey] as? String
                            let aHost:String? = host[.HostsHost] as? String
                            let aProtocol:String? = host[.HostsProtocol] as? String
                            if let key = aKey {
                                let pair = ProtocolHostPair(aProtocol, aHost)
                                hostMap.mappedPairs[key] = pair
                                hostMap.sortedKeys.append(key)
                                // if there is no host, consider this item editable
                                if aHost == nil {
                                    hostMap.editableKeys.append(key)
                                }
                                else if aHost!.contains(HostMap.editableHostAlphanumericPlaceholderExpression) {
                                    hostMap.editableKeys.append(key)
                                }
                                else if aHost!.contains(HostMap.editableHostNnumericPlaceholderExpression) {
                                    hostMap.editableKeys.append(key)
                                    hostMap.numericEditableKeys.append(key)
                                }
                            }
                        }
                    }

                    manager.hostMaps.append(hostMap)
                }
            }
        }
    }
}

private enum HostConfigurationKey:String {
            case CanonicalHost = "canonical_host"
            case CanonicalProtocol = "canonical_protocol"
            case ReleaseKey = "release_key"
            case PrereleaseKey = "prerelease_key"
            case Hosts = "hosts"
            case HostsKey = "key"
            case HostsHost = "host"
            case HostsProtocol = "protocol"
        }
        
private class NilMarker :NSObject {
    
}

extension Dictionary {
    
    fileprivate subscript(key:HostConfigurationKey) -> NSObject {
        for k in self.keys {
            if let kstring = k as? String {
                if kstring == key.rawValue {
                    return self[k]! as! NSObject
                }
            }
        }
            
        return NilMarker()
    }
}


private class HostMapCache {
    let squidKitHostMapCacheKey = "com.squidkit.hostMapCachePreferenceKey"

    typealias CacheDictionary = [String: [String: String]]
    
    var cacheStore:HostMapCacheStorable?

    required init(cacheStore:HostMapCacheStorable?) {
        self.cacheStore = cacheStore
    }

    func cacheKeyAndHost(_ key:String, mappedHost:String, forCanonicalHost canonicalHost:String) {
        var mutableCache:[String: AnyObject]?
        if let cache:[String: AnyObject] = cacheStore?.getEntry(squidKitHostMapCacheKey) {
            mutableCache = cache
        }
        else {
            mutableCache = [String: AnyObject]()
        }
        
        var dictionaryItem = [String: String]()
        dictionaryItem["key"] = key
        dictionaryItem["host"] = mappedHost
        mutableCache![canonicalHost] = dictionaryItem as AnyObject?
        
        cacheStore?.setEntry(mutableCache!, key: squidKitHostMapCacheKey)
    }

    
    func retreiveCachedKeyAndHostForCanonicalHost(_ canonicalHost:String) -> (String, String)? {
        var result:(String, String)?
        if let cache:[String: AnyObject] = cacheStore?.getEntry(squidKitHostMapCacheKey) {
            if let hostDict:[String: String] = cache[canonicalHost] as? [String: String] {
                result = (hostDict["key"]! , hostDict["host"]! )
            }
        }
        return result
    }

    func removeCachedKeyForCanonicalHost(_ canonicalHost:String) {
        if let cache:[String: AnyObject] = cacheStore?.getEntry(squidKitHostMapCacheKey) {
            var mutableCache = cache
            mutableCache.removeValue(forKey: canonicalHost)
            cacheStore?.setEntry(mutableCache, key: squidKitHostMapCacheKey)
        }
    }

    func removeAll() {
        cacheStore?.remove(squidKitHostMapCacheKey)
    }
}
