//
//  CapabilityOption.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

/// A response containing a list of resources.
public struct CapabilityOption: Codable {
    
    public let description: String?

    public let enabled: Bool?

    public let enabledByDefault: Bool?

    public let key: CapabilityOptionKey?

    public let name: String?
    
    public let supportsWildcard: Bool?
}
