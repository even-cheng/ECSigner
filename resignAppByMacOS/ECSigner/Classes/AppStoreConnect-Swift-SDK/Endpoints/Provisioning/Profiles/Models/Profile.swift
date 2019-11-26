//
//  Profile.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

/// The data structure that represents the resource.
public struct Profile: Codable {
    
    /// The resource's attributes.
    public let attributes: Profile.Attributes?
    
    /// The opaque resource ID that uniquely identifies the resource.
    public let `id`: String
    
    /// Navigational links to related data and included resource types and IDs.
    public let relationships: Profile.Relationships?
    
    /// The resource type.Value: userInvitations
    public let type: String = "profiles"
    
    /// Navigational links that include the self-link.
    public let links: ResourceLinks<Profile>
    
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let profileContent: String?
        
        public let name: String?
        
        public let platform: Platform?
        
        public let uuid: String?
        
        public let createdDate: Date?
        
        public let profileState: ProfileState?
        
        public let profileType: ProfileType?
        
        public let expirationDate: Date?
    }
    
    public struct Relationships: Codable {
        
        public let certificates: Profile.Relationships.Certificates?
        
        public let devices: Profile.Relationships.Devices?

        public let bundleId: Profile.Relationships.BundleId?
    }
}

/// MARK: BundleIDsResponsedData.Relationships
extension Profile.Relationships {
    
    public struct Certificates: Codable {
        
        public let data: [Profile.Relationships.Certificates.Data]?
        
        public let links: Profile.Relationships.Certificates.Links?
        
        /// PagingInformation
        public let meta: PagingInformation?
    }
    
    public struct Devices: Codable {
        
        public let data: [Profile.Relationships.Devices.Data]?
        
        public let links: Profile.Relationships.Devices.Links?
        
        /// PagingInformation
        public let meta: PagingInformation?
    }
    
    public struct BundleId: Codable {
        
        public let data: Profile.Relationships.BundleId.Data?
        
        public let links: Profile.Relationships.BundleId.Links?
    }
}

/// MARK: UserInvitation.Relationships.VisibleApps
extension Profile.Relationships.Certificates {
    
    public struct Data: Codable {
        
        /// The opaque resource ID that uniquely identifies the resource.
        public let `id`: String
        
        /// The resource type.Value: apps
        public let type: String = "certificates"
    }
    
    public struct Links: Codable {
        
        /// uri-reference
        public let related: URL?
        
        /// uri-reference
        public let `self`: URL?
    }
}

/// MARK: UserInvitation.Relationships.VisibleApps
extension Profile.Relationships.BundleId {
    
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

// MARK: UserInvitation.Relationships.VisibleApps
extension Profile.Relationships.Devices {
    
    public struct Data: Codable {
        
        /// The opaque resource ID that uniquely identifies the resource.
        public let `id`: String
        
        /// The resource type.Value: apps
        public let type: String = "devices"
    }
    
    public struct Links: Codable {
        
        /// uri-reference
        public let related: URL?
        
        /// uri-reference
        public let `self`: URL?
    }
}
