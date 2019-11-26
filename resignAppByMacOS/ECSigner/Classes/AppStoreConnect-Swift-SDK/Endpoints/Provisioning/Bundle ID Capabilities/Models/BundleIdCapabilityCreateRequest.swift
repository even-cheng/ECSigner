//
//  BundleIdCapabilityCreateRequest.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

// MARK: - Register
/// A request containing a single resource.
public struct BundleIdCapabilityCreateRequest: Codable {
    
    /// - Parameters:
    init(bundle_id: String,
        capabilityType: CapabilityType,
         settings: [CapabilitySetting]) {
        
        data = .init(
            attributes: .init(
                capabilityType: capabilityType,
                settings: settings),
            relationships: .init(
                bundleId: .init(data: .init(id: bundle_id)))
        )
    }
    
    /// The resource data.
    public let data: BundleIdCapabilityCreateRequest.Data
    
    public struct Data: Codable {
        
        /// The resource's attributes.
        public let attributes: BundleIdCapabilityCreateRequest.Data.Attributes
        
        /// The resource type.Value: userInvitations
        public let type: String = "bundleIdCapabilities"
        
        /// The resource's relationships.
        public let relationships: BundleIdCapabilityCreateRequest.Data.Relationships
    }
}

/// MARK: UserInvitationCreateRequest.Data
extension BundleIdCapabilityCreateRequest.Data {
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let capabilityType: CapabilityType?
        
        public let settings: [CapabilitySetting]?
    }
    
    /// Attributes that describe a resource.
    public struct Relationships: Codable {
        
        public let bundleId: BundleIdCapabilityCreateRequest.Data.Relationships.BundleId?
    }
}

/// MARK: BetaGroupCreateRequest.Data.Relationships
extension BundleIdCapabilityCreateRequest.Data.Relationships {
    
    public struct BundleId: Codable {
        
        /// [BetaGroupCreateRequest.Data.Relationships.Builds.Data]
        public let data: BundleIdCapabilityCreateRequest.Data.Relationships.BundleId.Data?
    }
}

/// MARK: BetaGroupCreateRequest.Data.Relationships.Builds
extension BundleIdCapabilityCreateRequest.Data.Relationships.BundleId {
    
    public struct Data: Codable {
        
        /// The opaque resource ID that uniquely identifies the resource.
        public let `id`: String
        
        /// The resource type.Value: builds
        public let type: String = "bundleIds"
    }
}
