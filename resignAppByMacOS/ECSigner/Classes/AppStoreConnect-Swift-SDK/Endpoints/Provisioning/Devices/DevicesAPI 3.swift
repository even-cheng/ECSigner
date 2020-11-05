//
//  DevicesAPI.swift
//  ECSigner
//
//  Created by Even on 2019/11/21.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

extension APIEndpoint where T == DeviceResponse {
    
    /// register a Bundle Id
    ///
    /// - Parameters:
    public static func registerNewDevice(
        name: String,
        udid: String,
        platform: String) -> APIEndpoint {
        
        let request = DeviceCreateRequest(
            name: name,
            udid: udid,
            platform: platform)
        return APIEndpoint(
            path: "devices",
            method: .post,
            parameters: nil,
            body: try? JSONEncoder().encode(request))
    }
    
    
    public static func readDevicefomation(
        id: String,
        fields: [ListDevices.Field]? = nil) -> APIEndpoint {
        
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        return APIEndpoint(path: "devices/\(id)", method: .get, parameters: parameters)
    }
    
    /// modifyRegisteredDevice
    ///
    /// - Parameters:
    public static func modifyRegisteredDevice(id: String,
                                              name: String,
                                              status: DeviceStatus) -> APIEndpoint {
        
        let request = DeviceUpdateRequest(
            id: id,
            name: name,
            status: status)
        
        return APIEndpoint(
            path: "devices/\(id)",
            method: .patch,
            parameters: nil,
            body: try? JSONEncoder().encode(request))
    }
}

extension APIEndpoint where T == DevicesResponse {
    
    public static func listDevices(
        fields: [ListDevices.Field]? = nil,
        filter: [ListDevices.Filter]? = nil,
        limit: Int? = nil,
        sort: [ListDevices.Sort]? = nil,
        next: PagedDocumentLinks? = nil) -> APIEndpoint {
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        if let limit = limit { parameters["limit"] = limit }
        if let sort = sort { parameters.add(sort) }
        if let filter = filter { parameters.add(filter) }
        if let nextCursor = next?.nextCursor { parameters["cursor"] = nextCursor }
        return APIEndpoint(path: "devices", method: .get, parameters: parameters)
    }
}


public struct ListDevices {
    
    /// Fields to return for included related types.
    public enum Field: NestableQueryParameter {
        case devices([Devices])
        
        static var key: String = "fields"
        var pair: Pair {
            switch self {
            case .devices(let value):
                return (Devices.key, value.map({ $0.pair.value }).joinedByCommas())
            }
        }
    }
    
    /// Attributes by which to sort.
    public enum Sort: String, CaseIterable, NestableQueryParameter {
        case nameAscending = "+name"
        case nameDescending = "-name"
        case idAscending = "+id"
        case idDescending = "-id"
        case udidAscending = "+udid"
        case udidDescending = "-udid"
        case platformAscending = "+platform"
        case platformDescending = "-platform"
        case statusAscending = "+status"
        case statusDescending = "-status"
        
        static var key: String = "sort"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    /// Attributes, relationships, and IDs by which to filter.
    public enum Filter: NestableQueryParameter {
        case id([String]), name([String]), udid([String]), platform([String]), status([String])
        
        static var key: String = "filter"
        var pair: Pair {
            switch self {
            case .id(let value):
                return ("id", value.joinedByCommas())
            case .udid(let value):
                return ("udid", value.joinedByCommas())
            case .name(let value):
                return ("name", value.joinedByCommas())
            case .platform(let value):
                return ("platform", value.joinedByCommas())
            case .status(let value):
                return ("status", value.joinedByCommas())
            }
        }
    }
}

extension ListDevices.Field {
    
    public enum Devices: String, CaseIterable, NestableQueryParameter {
        case addedDate, deviceClass, model, name, platform, status, udid
        
        static var key: String = "devices"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
}
