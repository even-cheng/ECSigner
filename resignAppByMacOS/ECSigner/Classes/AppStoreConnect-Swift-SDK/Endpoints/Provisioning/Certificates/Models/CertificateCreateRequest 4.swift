//
//  CertificateCreateRequest.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

// MARK: - Register
/// A request containing a single resource.
public struct CertificateCreateRequest: Codable {
    
    /// - Parameters:
    init(certificateType: CertificateType,
         csrContent: String) {
        
        data = .init(
            attributes: .init(
                certificateType: certificateType,
                csrContent: csrContent)
        )
    }
    
    /// The resource data.
    public let data: CertificateCreateRequest.Data
    
    public struct Data: Codable {
        
        /// The resource's attributes.
        public let attributes: CertificateCreateRequest.Data.Attributes
        
        /// The resource type.Value: userInvitations
        public let type: String = "certificates"
    }
}

/// MARK: UserInvitationCreateRequest.Data
extension CertificateCreateRequest.Data {
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let certificateType: CertificateType?
        
        public let csrContent: String?
    }
}
