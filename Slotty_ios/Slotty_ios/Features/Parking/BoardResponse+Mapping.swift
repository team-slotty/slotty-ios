//
//  BoardResponse+Mapping.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation

extension BoardResponse.Slot {
    /// 서버 상태 글자를 앱 상태로
    var spotStatus: ParkingSpotStatus {
        switch status {
        case "OCCUPIED": .occupied
        case "VISITING": .visiting
        case "UNIDENTIFIED": .unconfirmed
        case "NEEDS_CHECK": .needsCheck
        case "AVAILABLE": .empty
        default: .needsCheck // 앱이 아직 모르는 상태는 확인 필요로 표시
        }
    }
}
