//
//  BundleIDsAPI.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//
import Foundation

extension APIEndpoint where T == BundleIdResponse {
    
    /// register a Bundle Id
    ///
    /// - Parameters:
    public static func register(
        bundle_id: String,
        name: String,
        platform: Platform) -> APIEndpoint {
        let request = BundleIdCreateRequest(
            identifier: bundle_id, name: name, platform: platform)
        return APIEndpoint(
            path: "bundleIds",
            method: .post,
            parameters: nil,
            body: try? JSONEncoder().encode(request))
    }
    
    /// modify a Bundle Id
    ///
    /// - Parameters:
    public static func modifyBundleID(id: String, new_name: String) -> APIEndpoint {
        
        let request = BundleIdUpdateRequest(
            identifier: id, name: new_name)
        return APIEndpoint(
            path: "bundleIds/\(id)",
            method: .patch,
            parameters: nil,
            body: try? JSONEncoder().encode(request))
    }
}


extension APIEndpoint where T == Void {
    
    /// delete a Bundle Id
    ///
    /// - Parameters:
    public static func delete(id: String) -> APIEndpoint {
        
        return APIEndpoint(
            path: "bundleIds/\(id)",
            method: .delete,
            parameters: nil,
            body: nil)
    }
}

extension APIEndpoint where T == BundleIdsResponse {
    
    /// Get a list of the users on your team.
    ///
    /// - Parameters:
    ///   - fields: Fields to return for included related types.
    ///   - include: Relationship data to include in the response.
    ///   - limit: Number of resources to return.
    ///   - sort: Attributes by which to sort.
    ///   - filter: Attributes, relationships, and IDs by which to filter.
    ///   - next: The next URL to use as a base. See `PagedDocumentLinks`.
    public static func bundleIds(
        fields: [ListBundleIds.Field]? = nil,
        filter: [ListBundleIds.Filter]? = nil,
        include: [ListBundleIds.Include]? = nil,
        limit: [ListBundleIds.Limit]? = nil,
        sort: [ListBundleIds.Sort]? = nil,
        next: PagedDocumentLinks? = nil) -> APIEndpoint {
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        if let include = include { parameters.add(include) }
        if let limit = limit { parameters.add(limit) }
        if let sort = sort { parameters.add(sort) }
        if let filter = filter { parameters.add(filter) }
        if let nextCursor = next?.nextCursor { parameters["cursor"] = nextCursor }
        return APIEndpoint(path: "bundleIds", method: .get, parameters: parameters)
    }
}


extension APIEndpoint where T == BundleIdResponse {
    
    public static func bundleInfomation(
        withId id: String,
        fields: [ListBundleIds.Field]? = nil,
        include: [ListBundleIds.Include]? = nil,
        limit: [ListBundleIds.Limit]? = nil) -> APIEndpoint {
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        if let include = include { parameters.add(include) }
        if let limit = limit { parameters.add(limit) }
        return APIEndpoint(
            path: "bundleIds/\(id)",
            method: .get,
            parameters: parameters)
    }
}

extension APIEndpoint where T == BundleIdProfilesLinkagesResponse {
    
    public static func getAllProfileIdsForBundleId(
        withId id: String,
        limit: Int? = nil,
        next: PagedDocumentLinks? = nil) -> APIEndpoint {
        
        var parameters = [String: Any]()
        if let limit = limit { parameters["limit"] = limit }
        if let nextCursor = next?.nextCursor { parameters["cursor"] = nextCursor }
        return APIEndpoint(
            path: "bundleIds/\(id)/relationships/profiles",
            method: .get,
            parameters: parameters)
    }
}

extension APIEndpoint where T == ProfilesResponse {
    
    public static func listAllProfilesForBundleId(
        withId id: String,
        limit: Int? = nil,
        fields: [ListBundleIds.Field]? = nil,
        next: PagedDocumentLinks? = nil) -> APIEndpoint {
        
        var parameters = [String: Any]()
        if let limit = limit { parameters["limit"] = limit }
        if let nextCursor = next?.nextCursor { parameters["cursor"] = nextCursor }
        return APIEndpoint(
            path: "bundleIds/\(id)/profiles",
            method: .get,
            parameters: parameters)
    }
}

extension APIEndpoint where T == BundleIdBundleIdCapabilitiesLinkagesResponse {
    
    public static func getAllCapabilityIdsForBundleId(
        withId id: String,
        limit: Int? = nil,
        next: PagedDocumentLinks? = nil) -> APIEndpoint {
        
        var parameters = [String: Any]()
        if let limit = limit { parameters["limit"] = limit }
        if let nextCursor = next?.nextCursor { parameters["cursor"] = nextCursor }
        return APIEndpoint(
            path: "bundleIds/\(id)/relationships/bundleIdCapabilities",
            method: .get,
            parameters: parameters)
    }
}

extension APIEndpoint where T == BundleIdCapabilitiesResponse {
    
    public static func listAllCapabilitiesForBundleId(
        withId id: String,
        limit: Int? = nil,
        fields: [ListBundleIds.Field]? = nil,
        next: PagedDocumentLinks? = nil) -> APIEndpoint {
        
        var parameters = [String: Any]()
        if let limit = limit { parameters["limit"] = limit }
        if let nextCursor = next?.nextCursor { parameters["cursor"] = nextCursor }
        return APIEndpoint(
            path: "bundleIds/\(id)/bundleIdCapabilities",
            method: .get,
            parameters: parameters)
    }
}


public struct ListBundleIds {
    
    /// Fields to return for included related types.
    public enum Field: NestableQueryParameter {
        case bundleIds([BundleIds])
        case profiles([Profiles])
        case bundleIdCapabilities([BundleIdCapabilities])
        
        static var key: String = "fields"
        var pair: Pair {
            switch self {
            case .bundleIds(let value):
                return (BundleIds.key, value.map({ $0.pair.value }).joinedByCommas())
            case .profiles(let value):
                return (Profiles.key, value.map({ $0.pair.value }).joinedByCommas())
            case .bundleIdCapabilities(let value):
                return (BundleIdCapabilities.key, value.map({ $0.pair.value }).joinedByCommas())
            }
        }
    }
    
    /// Relationship data to include in the response.
    public enum Include: String, CaseIterable, NestableQueryParameter {
        case visibleApps
        
        static var key: String = "include"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    /// Number of resources to return.
    public enum Limit: NestableQueryParameter {
        case profiles(Int)
        
        static var key: String = "limit"
        var pair: Pair {
            switch self {
            case .profiles(let value):
                return ("profiles", "\(value)")
            }
        }
    }
    
    /// Attributes by which to sort.
    public enum Sort: String, CaseIterable, NestableQueryParameter {
        case nameAscending = "+name"
        case nameDescending = "-name"
        case idAscending = "+id"
        case idDescending = "-id"
        
        static var key: String = "sort"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    /// Attributes, relationships, and IDs by which to filter.
    public enum Filter: NestableQueryParameter {
        case id([String]), identifier([String]), name([String]), platform([String])
        
        static var key: String = "filter"
        var pair: Pair {
            switch self {
            case .id(let value):
                return ("id", value.joinedByCommas())
            case .identifier(let value):
                return ("identifier", value.joinedByCommas())
            case .name(let value):
                return ("name", value.joinedByCommas())
            case .platform(let value):
                return ("platform", value.joinedByCommas())
            }
        }
    }
}

extension ListBundleIds.Field {
    
    public enum BundleIds: String, CaseIterable, NestableQueryParameter {
        case bundleIdCapabilities, identifier, name, platform, profiles, seedId
        
        static var key: String = "bundleIds"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    public enum Profiles: String, CaseIterable, NestableQueryParameter {
        case bundleId, certificates, createdDate, devices, expirationDate, name, platform, profileContent, profileState, profileType, uuid
        
        static var key: String = "profiles"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    public enum BundleIdCapabilities: String, CaseIterable, NestableQueryParameter {
        case bundleId, capabilityType, settings
        
        static var key: String = "bundleIdCapabilities"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
}


