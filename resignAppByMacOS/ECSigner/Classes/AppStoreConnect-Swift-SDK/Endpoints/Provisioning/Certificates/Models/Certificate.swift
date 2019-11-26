//
//  Certificate.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation


/// The data structure that represents the resource.
public struct Certificate: Codable {
    
    /// The resource's attributes.
    public let attributes: Certificate.Attributes?
    
    /// The opaque resource ID that uniquely identifies the resource.
    public let `id`: String
   
    /// The resource type.Value: userInvitations
    public let type: String = "certificates"
    
    /// Navigational links that include the self-link.
    public let links: ResourceLinks<Certificate>
    
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let certificateContent: String?
        
        public let displayName: String?
        
        public let expirationDate: Date?

        public let platform: Platform?
        
        public let name: String?
        
        public let serialNumber: String?
        
        public let certificateType: CertificateType?
    }
}

