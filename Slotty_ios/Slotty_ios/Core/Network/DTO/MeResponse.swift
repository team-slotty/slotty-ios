//
//  MeResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 내 정보 응답 - GET /api/me
/// 세대 소속 여부, 빌라 이름, 연락처 공개를 쓴다 (관리자 여부는 필요할 때 추가)
struct MeResponse: Decodable {
    /// 소속 전이면 null
    let household: Household?
    /// 소속 빌라, 소속 전이면 null
    let villa: Villa?
    /// 차량번호 검색 시 연락처 공개 - 설정 화면에서만 써서 없어도 해석되게 옵셔널
    let phonePublic: Bool?
    
    struct Household: Decodable {
        let unitNumber: String
    }
    
    struct Villa: Decodable {
        let name: String
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

/// 내 정보 수정 요청 - PATCH /api/me (보낸 필드만 바뀐다)
struct MeUpdateRequest: Encodable {
    let phonePublic: Bool
}
