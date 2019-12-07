//
//  DeviceCreateRequest.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation


// MARK: - Register
/// A request containing a single resource.
public struct DeviceCreateRequest: Codable {
    
    /// - Parameters:
    init(name: String,
         udid: String,
         platform: String) {
        
        data = .init(
            attributes: .init(
                name: name,
                platform: Platform(rawValue: platform), udid: udid)
        )
    }
    
    /// The resource data.
    public let data: DeviceCreateRequest.Data
    
    public struct Data: Codable {
        
        /// The resource's attributes.
        public let attributes: DeviceCreateRequest.Data.Attributes
        
        /// The resource type.Value: userInvitations
        public let type: String = "devices"
    }
}

/// MARK: UserInvitationCreateRequest.Data
extension DeviceCreateRequest.Data {
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let name: String?

        public let platform: Platform?
        
        public let udid: String?
    }
}
