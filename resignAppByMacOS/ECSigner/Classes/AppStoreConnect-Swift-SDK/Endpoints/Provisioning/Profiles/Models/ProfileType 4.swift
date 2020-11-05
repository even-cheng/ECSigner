//
//  ProfileType.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

public enum ProfileType: String, Codable {
    case ios_development = "IOS_APP_DEVELOPMENT"
    case ios_store = "IOS_APP_STORE"
    case ios_adhoc = "IOS_APP_ADHOC"
    case ios_inhouse = "IOS_APP_INHOUSE"
    case mac_development = "MAC_APP_DEVELOPMENT"
    case mac_store = "MAC_APP_STORE"
    case mac_direct = "MAC_APP_DIRECT"
    case tv_development = "TVOS_APP_DEVELOPMENT"
    case tv_store = "TVOS_APP_STORE"
    case tv_adhoc = "TVOS_APP_ADHOC"
    case tv_inhouse = "TVOS_APP_INHOUSE"
}

public enum ProfileState: String, Codable {
    case active = "ACTIVE"
    case invalid = "INVALID"
}

