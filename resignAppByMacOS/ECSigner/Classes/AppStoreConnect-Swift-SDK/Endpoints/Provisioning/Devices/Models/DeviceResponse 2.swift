//
//  DeviceResponse.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

/// A response containing a list of resources.
public struct DeviceResponse: Codable {
    
    /// The resource data.
    public let data: Device
    
    /// Navigational links that include the self-link.
    public let links: PagedDocumentLinks
}
