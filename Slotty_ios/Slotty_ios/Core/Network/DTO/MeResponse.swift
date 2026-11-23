//
//  MeResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 내 정보 응답 - GET /api/me
/// 세대 소속 여부, 빌라 이름, 연락처 공개를 쓴다
struct MeResponse: Decodable {
    /// 소속 전이면 null
    let household: Household?
    /// 소속 빌라, 소속 전이면 null
    let villa: Villa?
    /// 차량번호 검색 시 연락처 공개 - 설정 화면에서만 써서 없어도 해석되게 옵셔널
    let phonePublic: Bool?
    /// 빌라 관리자인지 - 관리 탭을 보일지 정한다
    let isAdmin: Bool?
    
    struct Household: Decodable {
        let unitNumber: String
    }
    
    struct Villa: Decodable {
        let name: String
        /// 도착 알림 기준점 - 주소를 좌표로 못 바꿨으면 null
        let anchor: AnchorResponse?
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
