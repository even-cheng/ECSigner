//
//  BundleIdCapabilityUpdateRequest.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

// MARK: - Modify
/// A request containing a single resource.
public struct BundleIdCapabilityUpdateRequest: Codable {
    
    /// - Parameters:
    init(bundle_id: String,
        capabilityType: CapabilityType,
         settings: [CapabilitySetting]) {
        data = .init(
            attributes: .init(capabilityType: capabilityType, settings: settings),
            id: bundle_id
        )
    }
    
    /// The resource data.
    public let data: BundleIdCapabilityUpdateRequest.Data
    
    public struct Data: Codable {
        
        /// The resource's attributes.
        public let attributes: BundleIdCapabilityUpdateRequest.Data.Attributes
        
        /// The resource type.Value: userInvitations
        public let type: String = "bundleIdCapabilities"
        
        // The resource type.Value: userInvitations
        public let id: String?
    }
}

/// MARK: UserInvitationCreateRequest.Data
extension BundleIdCapabilityUpdateRequest.Data {
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let capabilityType: CapabilityType?
        
        public let settings: [CapabilitySetting]?
    }
}
