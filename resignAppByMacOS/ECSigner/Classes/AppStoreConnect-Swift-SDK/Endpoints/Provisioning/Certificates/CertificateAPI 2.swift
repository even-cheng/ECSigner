//
//  CertificateAPI.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

extension APIEndpoint where T == CertificateResponse {
    
    /// register a Bundle Id
    ///
    /// - Parameters:
    public static func creatCertificate(
        certificateType: CertificateType,
        csrContent: String) -> APIEndpoint {
        let request = CertificateCreateRequest(
            certificateType: certificateType, csrContent: csrContent)
        return APIEndpoint(
            path: "certificates",
            method: .post,
            parameters: nil,
            body: try? JSONEncoder().encode(request))
    }

    public static func readAndDownloadCertificateInfomation(
        id: String,
        fields: [ListCertificates.Field]? = nil) -> APIEndpoint {
        
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        return APIEndpoint(path: "certificates/\(id)", method: .get, parameters: parameters)
    }
}

extension APIEndpoint where T == CertificatesResponse {

    public static func listAndDownloadCertificates(
        fields: [ListCertificates.Field]? = nil,
        filter: [ListCertificates.Filter]? = nil,
        limit: Int? = nil,
        sort: [ListCertificates.Sort]? = nil,
        next: PagedDocumentLinks? = nil) -> APIEndpoint {
        var parameters = [String: Any]()
        if let fields = fields { parameters.add(fields) }
        if let limit = limit { parameters["limit"] = limit }
        if let sort = sort { parameters.add(sort) }
        if let filter = filter { parameters.add(filter) }
        if let nextCursor = next?.nextCursor { parameters["cursor"] = nextCursor }
        return APIEndpoint(path: "certificates", method: .get, parameters: parameters)
    }
}

extension APIEndpoint where T == Void {
    
    /// delete a Bundle Id
    ///
    /// - Parameters:
    public static func revokeCertificate(id: String) -> APIEndpoint {
        
        return APIEndpoint(
            path: "certificates/\(id)",
            method: .delete,
            parameters: nil,
            body: nil)
    }
}

public struct ListCertificates {
    
    /// Fields to return for included related types.
    public enum Field: NestableQueryParameter {
        case certificates([Certificates])
        
        static var key: String = "fields"
        var pair: Pair {
            switch self {
            case .certificates(let value):
                return (Certificates.key, value.map({ $0.pair.value }).joinedByCommas())
            }
        }
    }
  
    /// Attributes by which to sort.
    public enum Sort: String, CaseIterable, NestableQueryParameter {
        case cerTypeAscending = "+certificateType"
        case cerTypeDescending = "-certificateType"
        case displayNameAscending = "+displayName"
        case displayNameDescending = "-displayName"
        case idAscending = "+id"
        case idDescending = "-id"
        case serialNumberAscending = "+serialNumber"
        case serialNumberDescending = "-serialNumber"

        static var key: String = "sort"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
    
    /// Attributes, relationships, and IDs by which to filter.
    public enum Filter: NestableQueryParameter {
        case id([String]), serialNumber([String]), certificateType([String]), displayName([String])
        
        static var key: String = "filter"
        var pair: Pair {
            switch self {
            case .id(let value):
                return ("id", value.joinedByCommas())
            case .serialNumber(let value):
                return ("serialNumber", value.joinedByCommas())
            case .certificateType(let value):
                return ("certificateType", value.joinedByCommas())
            case .displayName(let value):
                return ("displayName", value.joinedByCommas())
            }
        }
    }
}

extension ListCertificates.Field {
    
    public enum Certificates: String, CaseIterable, NestableQueryParameter {
        case certificateContent, certificateType, csrContent, displayName, expirationDate, name, platform, serialNumber
        
        static var key: String = "certificates"
        var pair: NestableQueryParameter.Pair { return (nil, rawValue) }
    }
}
