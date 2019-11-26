//
//  BundleIdCapabilitiesAPI.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

extension APIEndpoint where T == BundleIdCapabilityResponse {
    
    /// register a Bundle Id
    ///
    /// - Parameters:
    public static func enableCapabilityForBundleId(
        bundle_id: String,
        capabilityType: CapabilityType,
        settings: [CapabilitySetting]) -> APIEndpoint {
        let request = BundleIdCapabilityCreateRequest(
            bundle_id: bundle_id, capabilityType: capabilityType, settings: settings)
        return APIEndpoint(
            path: "bundleIdCapabilities",
            method: .post,
            parameters: nil,
            body: try? JSONEncoder().encode(request))
    }
    
    /// modify a Bundle Id
    ///
    /// - Parameters:
    public static func modifyCapabilityConfiguration(bundle_id: String,
                                                     capabilityType: CapabilityType,
                                                     settings: [CapabilitySetting]) -> APIEndpoint {
        
        let request = BundleIdCapabilityUpdateRequest(
            bundle_id: bundle_id, capabilityType: capabilityType, settings: settings)
        
        return APIEndpoint(
            path: "bundleIdCapabilities/\(bundle_id)",
            method: .patch,
            parameters: nil,
            body: try? JSONEncoder().encode(request))
    }
}

extension APIEndpoint where T == Void {
    
    /// delete a Bundle Id
    ///
    /// - Parameters:
    public static func disableCapabilityForBundleId(bundle_id: String) -> APIEndpoint {
        
        return APIEndpoint(
            path: "bundleIdCapabilities/\(bundle_id)",
            method: .delete,
            parameters: nil,
            body: nil)
    }
}
