//
//  BundleId.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

/// The data structure that represents the resource.
public struct BundleId: Codable {
    
    /// The resource's attributes.
    public let attributes: BundleId.Attributes?
    
    /// The opaque resource ID that uniquely identifies the resource.
    public let `id`: String
    
    /// Navigational links to related data and included resource types and IDs.
    public let relationships: BundleId.Relationships?
    
    /// The resource type.Value: userInvitations
    public let type: String = "bundleIds"
    
    /// Navigational links that include the self-link.
    public let links: ResourceLinks<BundleId>
    
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let identifier: String?
        
        public let name: String?
        
        public let platform: Platform?
        
        public let seedId: String?
    }
    
    public struct Relationships: Codable {
        
        public let profiles: BundleId.Relationships.Profiles?
        
        public let bundleIdCapabilities: BundleId.Relationships.BundleIdCapabilities?
    }
}

/// MARK: BundleIDsResponsedData.Relationships
extension BundleId.Relationships {
    
    public struct Profiles: Codable {
        
        public let data: [BundleId.Relationships.Profiles.Data]?
        
        public let links: BundleId.Relationships.Profiles.Links?
        
        /// PagingInformation
        public let meta: PagingInformation?
    }
    
    public struct BundleIdCapabilities: Codable {
        
        public let data: [BundleId.Relationships.BundleIdCapabilities.Data]?
        
        public let links: BundleId.Relationships.BundleIdCapabilities.Links?
        
        /// PagingInformation
        public let meta: PagingInformation?
    }
}

/// MARK: UserInvitation.Relationships.VisibleApps
extension BundleId.Relationships.Profiles {
    
    public struct Data: Codable {
        
        /// The opaque resource ID that uniquely identifies the resource.
        public let `id`: String
        
        /// The resource type.Value: apps
        public let type: String = "profiles"
    }
    
    public struct Links: Codable {
        
        /// uri-reference
        public let related: URL?
        
        /// uri-reference
        public let `self`: URL?
    }
}

/// MARK: UserInvitation.Relationships.VisibleApps
extension BundleId.Relationships.BundleIdCapabilities {
    
    public struct Data: Codable {
        
        /// The opaque resource ID that uniquely identifies the resource.
        public let `id`: String
        
        /// The resource type.Value: apps
        public let type: String = "bundleIdCapabilities"
    }
    
    public struct Links: Codable {
        
        /// uri-reference
        public let related: URL?
        
        /// uri-reference
        public let `self`: URL?
    }
}
