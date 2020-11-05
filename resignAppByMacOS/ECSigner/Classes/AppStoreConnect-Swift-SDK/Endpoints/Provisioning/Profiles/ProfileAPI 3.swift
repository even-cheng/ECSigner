//
//  ProfileAPI.swift
//  ECSigner
//
//  Created by Even on 2019/11/21.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

extension APIEndpoint where T == ProfileResponse {
    
    /// register a Bundle Id
    ///
    /// - Parameters:
    public static func creatProfile(
        name: String,
        profileType: String,
        bundle_id: String,
        certificates:[String],
        devices:[String]) -> APIEndpoint {
        
        let request = ProfileCreateRequest(
            name: name,
            profileType: profileType,
            bundleId: bundle_id,
            certificates:certificates,
            devices: devices)
        
        return APIEndpoint(
            path: "profiles",
            method: .post,
            parameters: nil,
            body: try? JSONEncoder().encode(request))
    }
    
    public static func readAndDownloadProfilefomation(
        id: String,
        fields: [ListProfiles.Field]? = nil,
        include: [ListProfiles.Include]? = nil,
        limit: [ListProfiles.Limit]? = nil) -> APIEndpoint {
        
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        if let include = include { parameters.add(include) }
        if let limit = limit { parameters.add(limit) }
        return APIEndpoint(path: "profiles/\(id)", method: .get, parameters: parameters)
    }
}

extension APIEndpoint where T == Void {
    
    /// delete a Bundle Id
    ///
    /// - Parameters:
    public static func deleteProfile(id: String) -> APIEndpoint {
        
        return APIEndpoint(
            path: "profiles/\(id)",
            method: .delete,
            parameters: nil,
            body: nil)
    }
}

extension APIEndpoint where T == ProfilesResponse {
    
    public static func listAndDownloadProfiles(
        fields: [ListProfiles.Field]? = nil,
        filter: [ListProfiles.Filter]? = nil,
        include: [ListProfiles.Include]? = nil,
        limit: [ListProfiles.Limit]? = nil,
        sort: [ListProfiles.Sort]? = nil,
        next: PagedDocumentLinks? = nil) -> APIEndpoint {
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        if let limit = limit { parameters["limit"] = limit }
        if let sort = sort { parameters.add(sort) }
        if let filter = filter { parameters.add(filter) }
        if let nextCursor = next?.nextCursor { parameters["cursor"] = nextCursor }
        return APIEndpoint(path: "profiles", method: .get, parameters: parameters)
    }
}


public struct ListProfiles {
    
    /// Fields to return for included related types.
    public enum Field: NestableQueryParameter {
        case certificates([Certificates])
        case devices([Devices])
        case profiles([Profiles])
        case bundleIds([BundleIds])

        static var key: String = "fields"
        var pair: Pair {
            switch self {
            case .certificates(let value):
                return (Certificates.key, value.map({ $0.pair.value }).joinedByCommas())
            case .devices(let value):
                return (Devices.key, value.map({ $0.pair.value }).joinedByCommas())
            case .profiles(let value):
                return (Profiles.key, value.map({ $0.pair.value }).joinedByCommas())
            case .bundleIds(let value):
                return (BundleIds.key, value.map({ $0.pair.value }).joinedByCommas())
            }
        }
    }
    
    /// Relationship data to include in the response.
    public enum Include: String, CaseIterable, NestableQueryParameter {
        case bundleId
        case certificates
        case devices

        static var key: String = "include"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    /// Number of resources to return.
    public enum Limit: NestableQueryParameter {
        case certificates(Int)
        case devices(Int)

        static var key: String = "limit"
        var pair: Pair {
            switch self {
            case .certificates(let value):
                return ("certificates", "\(value)")
            case .devices(let value):
                return ("devices", "\(value)")
            }
        }
    }
    
    /// Attributes by which to sort.
    public enum Sort: String, CaseIterable, NestableQueryParameter {
        case nameAscending = "+name"
        case nameDescending = "-name"
        case idAscending = "+id"
        case idDescending = "-id"
        case profileTypeAscending = "+profileType"
        case profileTypeDescending = "-profileType"
        case profileStateAscending = "+profileState"
        case profileStateDescending = "-profileState"
        
        static var key: String = "sort"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    /// Attributes, relationships, and IDs by which to filter.
    public enum Filter: NestableQueryParameter {
        case id([String]), name([String]), profileState([String]), profileType([String])
        
        static var key: String = "filter"
        var pair: Pair {
            switch self {
            case .id(let value):
                return ("id", value.joinedByCommas())
            case .profileState(let value):
                return ("profileState", value.joinedByCommas())
            case .name(let value):
                return ("name", value.joinedByCommas())
            case .profileType(let value):
                return ("profileType", value.joinedByCommas())
            }
        }
    }
}

extension ListProfiles.Field {
    
    public enum Certificates: String, CaseIterable, NestableQueryParameter {
        case certificateContent, certificateType, csrContent, displayName, expirationDate, name, platform, serialNumber
        
        static var key: String = "certificates"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    public enum Devices: String, CaseIterable, NestableQueryParameter {
        case addedDate, deviceClass, model, name, platform, status, udid
        
        static var key: String = "devices"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    public enum Profiles: String, CaseIterable, NestableQueryParameter {
        case bundleId, certificates, createdDate, devices, expirationDate, name, platform, profileContent, profileState, profileType, uuid
        
        static var key: String = "profiles"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    public enum BundleIds: String, CaseIterable, NestableQueryParameter {
        case bundleIdCapabilities, identifier, name, platform, profiles, seedId
        
        static var key: String = "bundleIds"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
}


extension APIEndpoint where T == BundleIdResponse {
    
    public static func readTheBundleIdInProfle(
        id: String,
        fields: [ListProfiles.Field]? = nil) -> APIEndpoint {
        
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        return APIEndpoint(path: "profiles/\(id)/bundleId", method: .get, parameters: parameters)
    }
}


extension APIEndpoint where T == ProfileBundleIdLinkageResponse {
    
    public static func getTheBundleResourceIdInProfile(id: String) -> APIEndpoint {
        
        return APIEndpoint(path: "profiles/\(id)/relationships/bundleId", method: .get, parameters: nil)
    }
}


extension APIEndpoint where T == CertificatesResponse {
    
    public static func listAllCertificatesInProfile(
        id: String,
        fields: [ListProfiles.Field]? = nil,
        limit: Int? = nil) -> APIEndpoint {
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        if let limit = limit { parameters["limit"] = limit }
        return APIEndpoint(path: "profiles/\(id)/certificates", method: .get, parameters: parameters)
    }
}

extension APIEndpoint where T == ProfileCertificatesLinkagesResponse {
    
    public static func getAllCertificateIdsInProfile(
        id: String,
        limit: Int? = nil) -> APIEndpoint {
        var parameters = [String: Any]()
        if let limit = limit { parameters["limit"] = limit }
        return APIEndpoint(path: "profiles/\(id)/relationships/certificates", method: .get, parameters: parameters)
    }
}

extension APIEndpoint where T == DevicesResponse {
    
    public static func listAllDevicesInProfile(
        id: String,
        fields: [ListProfiles.Field]? = nil,
        limit: Int? = nil) -> APIEndpoint {
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        if let limit = limit { parameters["limit"] = limit }
        return APIEndpoint(path: "profiles/\(id)/devices", method: .get, parameters: parameters)
    }
}

extension APIEndpoint where T == ProfileDevicesLinkagesResponse {
    
    public static func getAllDeviceResourceIdsInProfile(
        id: String,
        limit: Int? = nil) -> APIEndpoint {
        var parameters = [String: Any]()
        if let limit = limit { parameters["limit"] = limit }
        return APIEndpoint(path: "profiles/\(id)/relationships/devices", method: .get, parameters: parameters)
    }
}
