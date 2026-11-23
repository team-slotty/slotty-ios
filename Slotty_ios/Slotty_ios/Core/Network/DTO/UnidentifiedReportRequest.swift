//
//  UnidentifiedReportRequest.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 미확인 차량 기록 요청 - POST /api/unidentified-reports (차량번호는 모르면 생략)
struct UnidentifiedReportRequest: Encodable {
    let slotId: Int
}

/// [내 차예요] 요청 - POST /api/unidentified-reports/{id}/mine
struct MarkAsMineRequest: Encodable {
    let vehicleId: Int
    /// 같은 탭을 다시 보내도 한 번만 바로잡히게 하는 값 (입차와 같은 방식)
    let clientRequestId: String
}
