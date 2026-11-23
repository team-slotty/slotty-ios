//
//  VisitResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 방문 등록 요청 - POST /api/visits (면을 생략하면 면 없이 등록)
struct VisitCreateRequest: Encodable {
    let plateNumber: String
    /// +09:00을 붙여 보낸다 (APIClient 날짜 규칙)
    let startAt: Date
    let endAt: Date
    let slotId: Int?
}

/// 본문이 필요 없는 POST에 보내는 빈 JSON - 예: [방문 종료]
struct EmptyBody: Encodable {}

/// 방문 목록 응답 - GET /api/visits?scope=
struct VisitPageResponse: Decodable {
    let items: [VisitResponse]
}

/// 방문 한 건 - 목록/등록/종료 공통
struct VisitResponse: Decodable {
    let visitId: Int
    let plateNumber: String
    let startAt: Date
    let endAt: Date
    /// 지정한 면, 면 없이 등록했으면 null
    let slotId: Int?
    /// 면 지정이 취소된 시각 - 취소됐으면 면이 없는 방문으로 본다
    let slotCancelledAt: Date?
    /// [방문 종료]로 끝낸 시각
    let endedAt: Date?
}

extension VisitResponse {
    /// 앱 모델로 변환 - 상태(예정/방문 중/확인 필요/종료)는 앱이 시각으로 계산한다
    func toVisit() -> Visit {
        Visit(
            id: String(visitId),
            plateNumber: plateNumber,
            startAt: startAt,
            endAt: endAt,
            spotNumber: slotCancelledAt == nil ? slotId : nil,
            endedAt: endedAt
        )
    }
}
