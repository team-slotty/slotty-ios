//
//  BoardResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation

/// GET /api/board 응답 - 서버 JSON 모양 그대로
struct BoardResponse: Decodable {
    let villaName: String
    let slots: [Slot]
    
    /// 주차면 한 칸
    struct Slot: Decodable {
        let number: Int
        /// 배정 세대, 공용 면이면 null
        let assignedUnit: String?
        /// 면 상태 (OCCUPIED/EMPTY)
        let status: String
        /// 서 있는 차, 빈 면이면 null
        let occupant: Occupant?
    }
    
    /// 면에 서 있는 차
    struct Occupant: Decodable {
        /// 차량번호, 미확인 차량이면 null
        let plateNumber: String?
        let enteredAt: Date
    }
}
