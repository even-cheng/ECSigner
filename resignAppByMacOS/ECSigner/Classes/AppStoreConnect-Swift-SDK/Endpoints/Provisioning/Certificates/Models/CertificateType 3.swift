//
//  CertificateType.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

public enum CertificateType: String, Codable {
   
    case ios_development = "IOS_DEVELOPMENT"
    case ios_distribution = "IOS_DISTRIBUTION"
    case mac_app_distribution = "MAC_APP_DISTRIBUTION"
    case mac_install_distribution = "MAC_INSTALLER_DISTRIBUTION"
    case mac_app_development = "MAC_APP_DEVELOPMENT"
    case developer_id_kext = "DEVELOPER_ID_KEXT"
    case developer_id_application = "DEVELOPER_ID_APPLICATION"
}
