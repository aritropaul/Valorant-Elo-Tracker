//
//  MatchModel.swift
//  ValorantTracker
//
//  Created by Aritro Paul on 05/01/21.
//

import Foundation

struct Matches: Codable {
    let version: Int
    let subject: String
    let matches: [Match]

    enum CodingKeys: String, CodingKey {
        case version = "Version"
        case subject = "Subject"
        case matches = "Matches"
    }
}

// MARK: - Match
struct Match: Codable {
    let matchID, mapID: String
    let matchStartTime, tierAfterUpdate, tierBeforeUpdate, tierProgressAfterUpdate: Int
    let tierProgressBeforeUpdate, rankedRatingEarned: Int
    let competitiveMovement: String

    enum CodingKeys: String, CodingKey {
        case matchID = "MatchID"
        case mapID = "MapID"
        case matchStartTime = "MatchStartTime"
        case tierAfterUpdate = "TierAfterUpdate"
        case tierBeforeUpdate = "TierBeforeUpdate"
        case tierProgressAfterUpdate = "TierProgressAfterUpdate"
        case tierProgressBeforeUpdate = "TierProgressBeforeUpdate"
        case rankedRatingEarned = "RankedRatingEarned"
        case competitiveMovement = "CompetitiveMovement"
    }
}

enum RiotError: Error {
    case invalidRequest
    case failedLogin
}

extension RiotError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidRequest :
            return "Invalid Request"
        case .failedLogin :
            return "Login Failed"
        }
    }
}
