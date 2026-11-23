//
//  VillaCreateRequest.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 빌라 만들기 요청 - POST /api/villas (만든 사람이 관리자, 내 호수의 세대원이 된다)
struct VillaCreateRequest: Encodable {
    let name: String
    let address: String
    let layoutTemplate: String
    let entranceSide: String
    let slotCount: Int
    let households: [Household]
    let myUnitNumber: String
    
    struct Household: Encodable {
        let unitNumber: String
    }
}

/// 빌라 만들기 응답 - 세대별 초대 코드
struct VillaCreateResponse: Decodable {
    let geocodeFailed: Bool
    let households: [Household]
    
    struct Household: Decodable {
        let unitNumber: String
        let inviteCode: String
    }
    
    func toResult() -> VillaCreateResult {
        VillaCreateResult(
            geocodeFailed: geocodeFailed,
            inviteCodes: households.map { .init(unitNumber: $0.unitNumber, code: $0.inviteCode) }
        )
    }
}
