//
//  CapabilityType.swift
//  ECSigner
//
//  Created by Even on 2019/11/20.
//  Copyright © 2019 Even_cheng. All rights reserved.
//

import Foundation

public enum CapabilityType: String, Codable {
    case icloud = "ICLOUD"
    case in_app_purchase = "IN_APP_PURCHASE"
    case game_center = "GAME_CENTER"
    case push_notifications = "PUSH_NOTIFICATIONS"
    case inter_app_audio = "INTER_APP_AUDIO"
    case maps = "MAPS"
    case associated_domains = "ASSOCIATED_DOMAINS"
    case person_vpn = "PERSONAL_VPN"
    case app_groups = "APP_GROUPS"
    case healthkit = "HEALTHKIT"
    case homekit = "HOMEKIT"
    case wireless_accessory_configuration = "WIRELESS_ACCESSORY_CONFIGURATION"
    case apple_pay = "APPLE_PAY"
    case data_protection = "DATA_PROTECTION"
    case sirikit = "SIRIKIT"
    case network_extension = "NETWORK_EXTENSIONS"
    case multipath = "MULTIPATH"
    case hot_spot = "HOT_SPOT"
    case nfc_tag_reading = "NFC_TAG_READING"
    case classkit = "CLASSKIT"
    case autofill_credential_provider = "AUTOFILL_CREDENTIAL_PROVIDER"
    case access_wifi_information = "ACCESS_WIFI_INFORMATION"
}

public enum CapabilityAllowedInstance: String, Codable {
    case entry = "ENTRY"
    case single = "SINGLE"
    case multiple = "MULTIPLE"
}

public enum CapabilityOptionKey: String, Codable {
    case xcode5 = "XCODE_5"
    case xcode6 = "XCODE_6"
    case complete_protection = "COMPLETE_PROTECTION"
    case protected_unless_open = "PROTECTED_UNLESS_OPEN"
    case protected_until_first_user_auth = "PROTECTED_UNTIL_FIRST_USER_AUTH"
}

public enum CapabilitySettingKey: String, Codable {
    case icloud_version = "ICLOUD_VERSION"
    case data_protection_permission_level = "DATA_PROTECTION_PERMISSION_LEVEL"
}
