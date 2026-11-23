//
//  VillaResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 빌라 기준점 좌표 - 도착 알림의 중심
struct AnchorResponse: Decodable {
    let latitude: Double
    let longitude: Double
}

/// 빌라 정보 응답 - GET /api/villas/me
struct VillaResponse: Decodable {
    let name: String
    let address: String
    /// LINE / DOUBLE / L_SHAPE
    let layoutTemplate: String
    /// TOP / BOTTOM / LEFT / RIGHT
    let entranceSide: String
    let slotCount: Int
    let householdCount: Int
    /// 주소를 좌표로 바꾸지 못했으면 null
    let anchor: AnchorResponse?
    
    func toInfo() -> VillaInfo {
        VillaInfo(
            name: name, address: address, layoutTemplate: layoutTemplate, entranceSide: entranceSide,
            slotCount: slotCount, householdCount: householdCount, hasAnchor: anchor != nil
        )
    }
}

/// 이름/주소 수정 요청 - PATCH /api/villas/me (보낸 필드만 바뀐다)
struct VillaUpdateRequest: Encodable {
    let name: String
    let address: String
}

/// 이름/주소 수정, 기준점 재설정 응답 - 주소를 좌표로 바꾸지 못했으면 geocodeFailed
struct GeocodeResultResponse: Decodable {
    let geocodeFailed: Bool
}

/// 기준점 재설정 요청 - PUT /api/villas/me/anchor (ADDRESS: 주소로 다시 변환)
struct AnchorRequest: Encodable {
    let mode: String
}

/// 관리자 위임 요청 - PUT /api/villas/me/admin
struct AdminDelegateRequest: Encodable {
    let userId: Int
}

/// 배치 변경 요청 - PUT /api/villas/me/layout (줄인 면에 기록이 있으면 SLOT_IN_USE)
struct LayoutRequest: Encodable {
    let layoutTemplate: String
    let entranceSide: String
    let slotCount: Int
}

/// 면 배정 요청 - PUT /api/parking-slots/assignments (세대 id가 없으면 공용)
struct SlotAssignmentRequest: Encodable {
    let assignments: [Assignment]
    
    struct Assignment: Encodable {
        let slotId: Int
        let householdId: Int?
    }
}

/// 면 배정 화면에 쓰는 현황판 면 - GET /api/parking-board (면 이름과 배정 세대만)
struct SlotListResponse: Decodable {
    let slots: [Slot]
    
    struct Slot: Decodable {
        let slotId: Int
        let label: String
        let assignedUnitNumber: String?
    }
}
