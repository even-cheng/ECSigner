//
//  BundleIdUpdateRequest.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation


// MARK: - Modify
/// A request containing a single resource.
public struct BundleIdUpdateRequest: Codable {
    
    /// - Parameters:
    init(identifier: String,
         name: String) {
        data = .init(
            attributes: .init(name: name),
            id: identifier
        )
    }
    
    /// The resource data.
    public let data: BundleIdUpdateRequest.Data
    
    public struct Data: Codable {
        
        /// The resource's attributes.
        public let attributes: BundleIdUpdateRequest.Data.Attributes
        
        /// The resource type.Value: userInvitations
        public let type: String = "bundleIds"
        
        // The resource type.Value: userInvitations
        public let id: String?
    }
}

/// MARK: UserInvitationCreateRequest.Data
extension BundleIdUpdateRequest.Data {
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let name: String?
    }
}
