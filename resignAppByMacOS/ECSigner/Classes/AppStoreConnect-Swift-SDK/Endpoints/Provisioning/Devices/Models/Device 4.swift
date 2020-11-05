//
//  Device.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

/// The data structure that represents the resource.
public struct Device: Codable {
    
    /// The resource's attributes.
    public let attributes: Device.Attributes?
    
    /// The opaque resource ID that uniquely identifies the resource.
    public let `id`: String
    
    /// The resource type.Value: userInvitations
    public let type: String = "devices"
    
    /// Navigational links that include the self-link.
    public let links: ResourceLinks<Device>
    
    /// Attributes that describe a resource.
    public struct Attributes: Codable {
        
        public let deviceClass: DeviceClass?
        
        public let model: String?
        
        public let name: String?
        
        public let platform: Platform?
        
        public let status: DeviceStatus?
        
        public let udid: String?
        
        public let addedDate: Date?
    }
}

public enum DeviceClass: String, Codable {
    case apple_watch = "APPLE_WATCH"
    case ipad = "IPAD"
    case iphone = "IPHONE"
    case ipod = "IPOD"
    case apple_tv = "APPLE_TV"
    case mac = "MAC"
}

public enum DeviceStatus: String, Codable {
    case enable = "ENABLED"
    case disable = "DISABLED"
}
