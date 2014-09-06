//
//  EndpointMap.swift
//  SquidKit
//
//  Created by Mike Leavy on 8/27/14.
//  Copyright (c) 2014 SquidKit. All rights reserved.
//

import Foundation

private let _EndpointMapperSharedInstance = EndpointMapper()

public struct ProtocolHostPair: Printable, DebugPrintable {
    public var hostProtocol:String?
    public var host:String?
    
    public init(_ hostProtocol:String?, _ host:String?) {
        self.hostProtocol = hostProtocol
        self.host = host
    }
    
    public var description: String {
        return "ProtocolHostPair: protocol = \(hostProtocol); host = \(host)"
    }

    public var debugDescription: String {
        return self.description
    }

}

func == (left:ProtocolHostPair, right:ProtocolHostPair) -> Bool {
    return left.host == right.host && left.hostProtocol == right.hostProtocol
}

public class EndpointMapper {
    
    private var mappedHosts = [String: ProtocolHostPair]()
    
    private init() {
        
    }
    
    public class var sharedInstance: EndpointMapper {
        return _EndpointMapperSharedInstance
    }
    
    public class func addProtocolHostMappedPair(mappedPair:ProtocolHostPair, canonicalHost:String) {
        EndpointMapper.sharedInstance.mappedHosts[canonicalHost] = mappedPair
    }
    
    public class func removeProtocolHostMappedPair(canonicalHost:String) {
        EndpointMapper.sharedInstance.mappedHosts[canonicalHost] = nil
    }
    
    internal class func mappedPairForCanonicalHost(canonicalHost:String) -> (ProtocolHostPair?) {
        return EndpointMapper.sharedInstance.mappedHosts[canonicalHost]
    }
    
}

public protocol HostMapCache {
    func cacheKeyAndHost(key:String, mappedHost:String, forCanonicalHost canonicalHost:String)
    func retreiveCachedKeyAndHostForCanonicalHost(canonicalHost:String) -> (String, String)?
    func removeCachedKeyForCanonicalHost(canonicalHost:String)
    func removeAll()
}

public class HostMap {
    public let canonicalProtocolHost:ProtocolHostPair
    
    public var releaseKey = ""
    public var prereleaseKey = ""
    public var mappedPairs = [String: ProtocolHostPair]()
    public var sortedKeys = [String]()
    public var editableKeys = [String]()

    public var canonicalHost:String {
        if let host = canonicalProtocolHost.host {
            return host
        }
        return ""
    }
    
    public init(canonicalProtocolHostPair:ProtocolHostPair) {
        self.canonicalProtocolHost = canonicalProtocolHostPair
    }
    
    public func pairWithKey(key:String) -> ProtocolHostPair? {
        return mappedPairs[key]
    }

    public func isEditable(key:String) -> Bool {
        return contains(editableKeys, key)
    }
}

private let _HostMapManagerSharedInstance = HostMapManager()

public class HostMapManager {
    public var hostMaps = [HostMap]()

    public var hostMapCache:HostMapCache? {
        return SquidKitHostMapCache()
    }
    
    private init() {
        
    }
    
    public class var sharedInstance: HostMapManager {
        return _HostMapManagerSharedInstance
    }

    public func loadConfigurationMapFromResourceFile(fileName:String) -> Bool {
        let result = HostConfigurationsLoader.loadConfigurationsFromResourceFile(fileName)
        self.restoreFromCache()
        return result
    }

    public func setReleaseConfigurations() {
        for hostMap in self.hostMaps {
            if let releasePair = hostMap.pairWithKey(hostMap.releaseKey) {
                EndpointMapper.addProtocolHostMappedPair(releasePair, canonicalHost: hostMap.canonicalHost)
            }
        }
    }

    public func setPrereleaseConfigurations() {
        for hostMap in self.hostMaps {
            if let preReleasePair = hostMap.pairWithKey(hostMap.prereleaseKey) {
                EndpointMapper.addProtocolHostMappedPair(preReleasePair, canonicalHost: hostMap.canonicalHost)
            }
        }
    }

    public func setConfigurationForCanonicalHost(configurationKey:String, mappedHost:String?, canonicalHost:String, withCaching:Bool = true) {
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
                        if let cacher = self.hostMapCache {
                            if !empty {
                                cacher.cacheKeyAndHost(configurationKey, mappedHost:runtimePair!.host!, forCanonicalHost: canonicalHost)
                            }
                            else {
                                cacher.removeCachedKeyForCanonicalHost(canonicalHost)
                            }
                        }
                    }
                }
                break
            }
        }
    }


    private func restoreFromCache() {
        if let mapCache = self.hostMapCache {
            for hostMap in self.hostMaps {
                if let (key, host) = mapCache.retreiveCachedKeyAndHostForCanonicalHost(hostMap.canonicalHost) {
                    self.setConfigurationForCanonicalHost(key, mappedHost:host, canonicalHost: hostMap.canonicalHost, withCaching: false)
                }
            }
        }
    }

    private class HostConfigurationsLoader {
    
        private class func loadConfigurationsFromResourceFile(fileName:String) -> Bool {
            var result = false
            
            if let hostDictionary = NSDictionary.dictionaryFromResourceFile(fileName) {
                result = true
                
                if let configurations:NSArray = hostDictionary.objectForKey("configurations") as? NSArray {
                    
                    for configuration in configurations {
                        HostConfigurationsLoader.handleConfiguration(configuration)
                    }
                    
                }
                
            }
            
            return result
        }

        

        
        private class func handleConfiguration(configuration:AnyObject) {
            if let config:[String: AnyObject] = configuration as? [String: AnyObject] {
                let canonicalHost:String? = config[.CanonicalHost] as? String
                let canonicalProtocol:String? = config[.CanonicalProtocol] as? String
                let releaseKey:String? = config[.ReleaseKey] as? String
                let prereleaseKey:String? = config[.PrereleaseKey] as? String

                if canonicalHost != nil && canonicalProtocol != nil {
                    var hostMap = HostMap(canonicalProtocolHostPair:ProtocolHostPair(canonicalProtocol, canonicalHost))
                    
                    if let release = releaseKey {
                        hostMap.releaseKey = release
                    }
                    if let prerelease = prereleaseKey {
                        hostMap.prereleaseKey = prerelease
                    }

                    if let hostsArray:[[String: String]] = config[.Hosts] as? [[String: String]] {
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
                            }
                        }
                    }

                    HostMapManager.sharedInstance.hostMaps.append(hostMap)
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
    
    private subscript(key:HostConfigurationKey) -> NSObject {
        for k in self.keys {
            if let kstring = k as? String {
                if kstring == key.toRaw() {
                    return self[k]! as NSObject
                }
            }
        }
            
        return NilMarker()
    }
}


public class SquidKitHostMapCache: HostMapCache {
    let squidKitHostMapCacheKey = "com.squidkit.hostMapCachePreferenceKey"

    typealias CacheDictionary = [String: [String: String]]

    init() {

    }

    public func cacheKeyAndHost(key:String, mappedHost:String, forCanonicalHost canonicalHost:String) {
        let prefs = Preferences()
        var mutableCache:NSMutableDictionary?
        if let cache:NSDictionary = prefs.preference(squidKitHostMapCacheKey) as? NSDictionary {
            mutableCache = (cache.mutableCopy() as NSMutableDictionary)
        }
        else {
            mutableCache = NSMutableDictionary()
        }
        
        var dictionaryItem = NSMutableDictionary()
        dictionaryItem.setObject(key, forKey: "key")
        dictionaryItem.setObject(mappedHost, forKey: "host")
        mutableCache!.setObject(dictionaryItem, forKey: canonicalHost)

        prefs.setPreference(mutableCache!, key:squidKitHostMapCacheKey)

        let thing:AnyObject? = prefs.preference(squidKitHostMapCacheKey)
    }

    
    public func retreiveCachedKeyAndHostForCanonicalHost(canonicalHost:String) -> (String, String)? {
        var result:(String, String)?
        let prefs = Preferences()
        if let cache:NSDictionary = prefs.preference(squidKitHostMapCacheKey) as? NSDictionary {
            if let hostDict:NSDictionary = cache[canonicalHost]? as? NSDictionary {
                result = (hostDict["key"]! as String, hostDict["host"]! as String)
            }
        }
        return result
    }

    public func removeCachedKeyForCanonicalHost(canonicalHost:String) {
        let prefs = Preferences()
        if let cache:NSDictionary = prefs.preference(squidKitHostMapCacheKey) as? NSDictionary {
            var mutableCache:NSMutableDictionary = (cache.mutableCopy() as NSMutableDictionary)
            mutableCache.removeObjectForKey(canonicalHost)
            prefs.setPreference(mutableCache, key:squidKitHostMapCacheKey)
        }
    }

    public func removeAll() {
        let prefs = Preferences()
        prefs.remove(squidKitHostMapCacheKey)
    }
}
