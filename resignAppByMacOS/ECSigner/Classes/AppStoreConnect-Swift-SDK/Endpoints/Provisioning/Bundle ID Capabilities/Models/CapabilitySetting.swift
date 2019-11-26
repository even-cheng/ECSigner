//
//  CapabilitySetting.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

/// A response containing a list of resources.
public struct CapabilitySetting: Codable {
    
    /// The resource data.
    public let allowedInstances: CapabilityAllowedInstance
    
    /// The requested relationship data.
    public let description: String?
    
    /// Navigational links that include the self-link.
    public let enabledByDefault: Bool?
    
    public let key: CapabilitySettingKey?
    
    public let name: String?
    
    public let options: [CapabilityOption]?
    
    public let visible: Bool?

    public let minInstances: Int?

}
