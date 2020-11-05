//
//  ProfileCreateRequest.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

// MARK: - Register
/// A request containing a single resource.
public struct ProfileCreateRequest: Codable {
    
    /// - Parameters:
    init(name: String,
         profileType: String,
         bundleId: String,
         certificates:[String],
         devices:[String]) {
        
        data = .init(
            attributes: .init(
                profileType: profileType,
                name: name),
            relationships: .init(
                bundleId: ProfileCreateRequest.Data.Relationships.BundleId.init(data: ProfileCreateRequest.Data.Relationships.BundleId.Data(id: bundleId)),
                certificates: ProfileCreateRequest.Data.Relationships.Certificates.init(data: certificates.map({ Data.Relationships.Certificates.Data(id: $0) })),
                devices: ProfileCreateRequest.Data.Relationships.Devices.init(data: devices.map({ Data.Relationships.Devices.Data(id: $0) })))
        )
    }
    
    /// The resource data.
    public let data: ProfileCreateRequest.Data
    
    public struct Data: Codable {
        
        /// The resource's attributes.
        public let attributes: ProfileCreateRequest.Data.Attributes
        
        /// The resource type.Value: userInvitations
        public let type: String = "profiles"
        
        /// The resource's relationships.
        public let relationships: ProfileCreateRequest.Data.Relationships
    }
}

/// MARK: UserInvitationCreateRequest.Data
extension ProfileCreateRequest.Data {
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let profileType: String?
        
        public let name: String?
    }
    
    /// Attributes that describe a resource.
    public struct Relationships: Codable {
        
        public let bundleId: ProfileCreateRequest.Data.Relationships.BundleId?

        public let certificates: ProfileCreateRequest.Data.Relationships.Certificates?

        public let devices: ProfileCreateRequest.Data.Relationships.Devices?
    }
}

/// MARK: BetaGroupCreateRequest.Data.Relationships
extension ProfileCreateRequest.Data.Relationships {
    
    public struct BundleId: Codable {
        
        /// [BetaGroupCreateRequest.Data.Relationships.Builds.Data]
        public let data: ProfileCreateRequest.Data.Relationships.BundleId.Data?
    }
    public struct Certificates: Codable {
        
        /// [BetaGroupCreateRequest.Data.Relationships.Builds.Data]
        public let data: [ProfileCreateRequest.Data.Relationships.Certificates.Data]?
    }
    public struct Devices: Codable {
        
        /// [BetaGroupCreateRequest.Data.Relationships.Builds.Data]
        public let data: [ProfileCreateRequest.Data.Relationships.Devices.Data]?
    }
}


/// MARK: BetaGroupCreateRequest.Data.Relationships.Builds
extension ProfileCreateRequest.Data.Relationships.BundleId {
    
    public struct Data: Codable {
        
        /// The opaque resource ID that uniquely identifies the resource.
        public let `id`: String
        
        /// The resource type.Value: builds
        public let type: String = "bundleIds"
    }
}

/// MARK: BetaGroupCreateRequest.Data.Relationships.Builds
extension ProfileCreateRequest.Data.Relationships.Certificates {
    
    public struct Data: Codable {
        
        /// The opaque resource ID that uniquely identifies the resource.
        public let `id`: String
        
        /// The resource type.Value: builds
        public let type: String = "certificates"
    }
}

/// MARK: BetaGroupCreateRequest.Data.Relationships.Builds
extension ProfileCreateRequest.Data.Relationships.Devices {
    
    public struct Data: Codable {
        
        /// The opaque resource ID that uniquely identifies the resource.
        public let `id`: String
        
        /// The resource type.Value: builds
        public let type: String = "devices"
    }
}
