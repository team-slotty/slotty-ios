//
//  CheckInOptionsResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 입차 옵션 응답 - GET /api/parking/check-in-options
/// 차량 목록(mode, vehicles)은 앱이 내 차량 카드로 고르고 있어서 면 정보만 받는다
struct CheckInOptionsResponse: Decodable {
    let slots: Slots
    
    struct Slots: Decodable {
        let suggestedSlotId: Int?
        let assignedAllOccupied: Bool
        let options: [Option]
    }
    
    struct Option: Decodable {
        /// 면 id - 현황판의 면 번호와 같다
        let slotId: Int
        /// 예: 6번
        let label: String
        /// ASSIGNED(내 배정 면) / COMMON(공용 면)
        let type: String
    }
}

extension CheckInOptionsResponse {
    /// 앱 모델로 변환 - 서버가 정한 순서를 그대로 쓴다
    func toOptions() -> CheckInOptions {
        CheckInOptions(
            spotNumbers: slots.options.map(\.slotId),
            suggestedSpotNumber: slots.suggestedSlotId,
            assignedAllOccupied: slots.assignedAllOccupied
        )
    }
}
