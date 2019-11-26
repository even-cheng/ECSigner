//
//  BundleIdCapability.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

/// The data structure that represents the resource.
public struct BundleIdCapability: Codable {
    
    /// The resource's attributes.
    public let attributes: BundleIdCapability.Attributes?
    
    /// The opaque resource ID that uniquely identifies the resource.
    public let `id`: String
    
    /// Navigational links to related data and included resource types and IDs.
    public let relationships: BundleIdCapability.Relationships?
    
    /// The resource type.Value: userInvitations
    public let type: String = "bundleIdCapabilities"
    
    /// Navigational links that include the self-link.
    public let links: ResourceLinks<BundleIdCapability>
    
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let capabilityType: CapabilityType?
        
        public let settings: [CapabilitySetting]?
    }
    
    public struct Relationships: Codable {
        
        public let bundleId: BundleIdCapability.Relationships.BundleId?
    }
}

/// MARK: BundleIDsResponsedData.Relationships
extension BundleIdCapability.Relationships {
    
    public struct BundleId: Codable {
        
        public let data: [BundleIdCapability.Relationships.BundleId.Data]?
        
        public let links: BundleIdCapability.Relationships.BundleId.Links?
        
        /// PagingInformation
        public let meta: PagingInformation?
    }
}

/// MARK: UserInvitation.Relationships.VisibleApps
extension BundleIdCapability.Relationships.BundleId {
    
    public struct Data: Codable {
        
        /// The opaque resource ID that uniquely identifies the resource.
        public let `id`: String
        
        /// The resource type.Value: apps
        public let type: String = "bundleIds"
    }
    
    public struct Links: Codable {
        
        /// uri-reference
        public let related: URL?
        
        /// uri-reference
        public let `self`: URL?
    }
}
