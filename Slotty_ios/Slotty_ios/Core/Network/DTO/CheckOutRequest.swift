//
//  CheckOutRequest.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 출차 옵션 응답 - GET /api/parking/check-out-options
/// 주차 중인 우리 세대 차와 그 차가 서 있는 면
struct CheckOutOptionsResponse: Decodable {
    let vehicles: [Vehicle]
    
    struct Vehicle: Decodable {
        let vehicleId: Int
        /// 서 있는 면 id - 현황판의 면 번호와 같다
        let slotId: Int
    }
}

/// 출차 요청 - POST /api/parking/check-out
/// exitedAt을 보내지 않으면 서버가 받은 시각으로 기록한다
struct CheckOutRequest: Encodable {
    let vehicleId: Int
    /// MANUAL(직접 출차) / NOTIFICATION(출발 알림에서 출차)
    let method: String
}

/// 출차 응답 - 앱은 바로 현황판을 다시 불러와서 기록 id만 받는다
struct CheckOutResponse: Decodable {
    let recordId: Int
}
