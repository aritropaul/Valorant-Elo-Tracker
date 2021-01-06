//
//  UserModel.swift
//  ValorantTracker
//
//  Created by Aritro Paul on 05/01/21.
//

import Foundation

struct User: Codable {
    let country, sub, playerLocale: String
    let acct: Account

    enum CodingKeys: String, CodingKey {
        case country, sub
        case playerLocale = "player_locale"
        case acct
    }
}

// MARK: - Acct
struct Account: Codable {
    let type: Int
    let state: String
    let adm: Bool
    let gameName, tagLine: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case type, state, adm
        case gameName = "game_name"
        case tagLine = "tag_line"
        case createdAt = "created_at"
    }
}
