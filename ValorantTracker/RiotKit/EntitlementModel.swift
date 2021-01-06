//
//  EntitlementModel.swift
//  ValorantTracker
//
//  Created by Aritro Paul on 05/01/21.
//

import Foundation

struct EntitlementToken: Codable {
    let entitlementsToken: String

    enum CodingKeys: String, CodingKey {
        case entitlementsToken = "entitlements_token"
    }
}
