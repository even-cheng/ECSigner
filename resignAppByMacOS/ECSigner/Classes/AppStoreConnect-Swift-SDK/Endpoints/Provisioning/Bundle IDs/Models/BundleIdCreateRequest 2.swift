//
//  BundleIDsRequest.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

// MARK: - Register
/// A request containing a single resource.
public struct BundleIdCreateRequest: Codable {
    
    /// - Parameters:
    init(identifier: String,
         name: String,
         platform: Platform) {
        
        data = .init(
            attributes: .init(
                identifier: identifier,
                name: name,
                platform: platform)
            )
    }
    
    /// The resource data.
    public let data: BundleIdCreateRequest.Data
    
    public struct Data: Codable {
        
        /// The resource's attributes.
        public let attributes: BundleIdCreateRequest.Data.Attributes
        
        /// The resource type.Value: userInvitations
        public let type: String = "bundleIds"
    }
}

/// MARK: UserInvitationCreateRequest.Data
extension BundleIdCreateRequest.Data {
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let identifier: String?
        
        public let name: String?
        
        public let platform: Platform?    
    }
}


