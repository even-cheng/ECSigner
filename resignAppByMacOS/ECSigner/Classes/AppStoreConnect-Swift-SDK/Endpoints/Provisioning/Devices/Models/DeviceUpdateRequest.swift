//
//  DeviceUpdateRequest.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

// MARK: - Register
/// A request containing a single resource.
public struct DeviceUpdateRequest: Codable {
    
    /// - Parameters:
    init(id: String,
         name: String,
         status: DeviceStatus) {
        
        data = .init(
            attributes: .init(
                name: name,
                status: status),
            id: id
        )
    }
    
    /// The resource data.
    public let data: DeviceUpdateRequest.Data
    
    public struct Data: Codable {
        
        /// The resource's attributes.
        public let attributes: DeviceUpdateRequest.Data.Attributes
        
        /// The resource type.Value: userInvitations
        public let type: String = "devices"
        
        public let id: String?
    }
}

/// MARK: UserInvitationCreateRequest.Data
extension DeviceUpdateRequest.Data {
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let name: String?
        
        public let status: DeviceStatus?
    }
}
