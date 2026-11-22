//
//  CheckInRequest.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 입차 요청 - POST /api/parking/check-in
/// enteredAt을 보내지 않으면 서버가 받은 시각으로 기록한다
struct CheckInRequest: Encodable {
    let vehicleId: Int
    let slotId: Int
    /// MANUAL(직접 입차) / NOTIFICATION(도착 알림에서 입차)
    let method: String
    /// 같은 탭을 다시 보내도 한 번만 기록되게 하는 값 - 탭할 때 한 번 만든다
    let clientRequestId: String
}

/// 입차 응답 - 앱은 바로 현황판을 다시 불러와서 기록 id만 받는다
struct CheckInResponse: Decodable {
    let recordId: Int
}
