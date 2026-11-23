//
//  HouseholdSummaryResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 관리자 세대 목록 한 줄 - GET /api/households
struct HouseholdSummaryResponse: Decodable {
    let householdId: Int
    let unitNumber: String
    let inviteCode: String
    let slotLabels: [String]
    let vehicleCount: Int
    let members: [Member]
    
    struct Member: Decodable {
        let userId: Int
        let name: String
        let isAdmin: Bool
    }
    
    func toHousehold() -> AdminHousehold {
        AdminHousehold(
            id: householdId, unitNumber: unitNumber, inviteCode: inviteCode,
            spotLabels: slotLabels, vehicleCount: vehicleCount,
            members: members.map { .init(id: $0.userId, name: $0.name, isAdmin: $0.isAdmin) }
        )
    }
}

/// 세대 추가 요청 - POST /api/households
struct HouseholdCreateRequest: Encodable {
    let unitNumber: String
}
