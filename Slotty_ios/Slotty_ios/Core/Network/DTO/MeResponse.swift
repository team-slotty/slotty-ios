//
//  MeResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 내 정보 응답 - GET /api/me
/// 지금은 세대 소속 여부만 쓴다 (관리자 여부, 빌라 정보는 필요할 때 추가)
struct MeResponse: Decodable {
    /// 소속 전이면 null
    let household: Household?
    
    struct Household: Decodable {
        let unitNumber: String
    }
}

/// 초대 코드 참여 요청 - POST /api/households/join
struct JoinHouseholdRequest: Encodable {
    let inviteCode: String
}

/// 초대 코드 참여 응답 - 참여한 세대
struct JoinHouseholdResponse: Decodable {
    let household: MeResponse.Household
}
