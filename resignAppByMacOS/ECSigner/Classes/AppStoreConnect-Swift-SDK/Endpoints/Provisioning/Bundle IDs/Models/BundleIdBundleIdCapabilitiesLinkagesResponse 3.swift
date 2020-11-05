//
//  BundleIdBundleIdCapabilitiesLinkagesResponse.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

/// A response containing a list of resources.
public struct BundleIdBundleIdCapabilitiesLinkagesResponse: Codable {
    
    /// The resource data.
    public let data: [BundleIdBundleIdCapabilitiesLinkagesResponse.Data]
        
    /// The requested relationship data.
    public let meta: PagingInformation?
    
    /// Navigational links that include the self-link.
    public let links: PagedDocumentLinks
}

/// MARK: UserInvitationCreateRequest.Data
extension BundleIdBundleIdCapabilitiesLinkagesResponse{
   
    /// Attributes that describe a resource.
    public struct Data: Codable {
        
        public let id: String?
        
        public let type = "bundleIdCapabilities"
    }
}
