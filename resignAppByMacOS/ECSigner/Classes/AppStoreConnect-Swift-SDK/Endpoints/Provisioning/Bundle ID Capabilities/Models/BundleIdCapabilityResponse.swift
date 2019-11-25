//
//  BundleIdCapabilityResponse.swift
//  ECSigner
//
//  Created by 快游 on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

/// A response containing a list of resources.
public struct BundleIdCapabilityResponse: Codable {
    
    /// The resource data.
    public let data: BundleIdCapability
    
    /// Navigational links that include the self-link.
    public let links: PagedDocumentLinks
}
