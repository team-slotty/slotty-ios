//
//  ParkingBoardResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 주차 현황판 응답 - GET /api/parking-board
/// 면 상태 전체(미확인/방문/가용 포함)와 미확인 기록 id가 있다
struct ParkingBoardResponse: Decodable {
    let slots: [Slot]
    
    /// 주차면 한 칸
    struct Slot: Decodable {
        /// 면 id - 앱의 면 번호로 쓴다
        let slotId: Int
        /// 배정 세대, 공용 면이면 null
        let assignedUnitNumber: String?
        /// UNIDENTIFIED / OCCUPIED / NEEDS_CHECK / VISITING / VISIT_SCHEDULED / AVAILABLE / EMPTY
        let status: String
        /// 서 있는 차, 빈 면이면 null
        let occupant: Occupant?
        /// 미확인 기록 id - [차량 떠남], [내 차예요]에 쓴다, 미확인이 아니면 null
        let unidentifiedReportId: Int?
    }
    
    /// 면에 서 있는 차
    struct Occupant: Decodable {
        let plateLast4: String
        /// 내 세대 차량일 때만 전체 번호, 그 외 null
        let plateNumber: String?
        /// 들어온 시각
        let since: Date
    }
}

extension ParkingBoardResponse {
    /// 앱 모델로 변환 - 빌라 이름, 내 세대, 내 차량은 다른 응답에서 받는다
    func toBoard(villaName: String, myUnit: String, myVehicles: [Vehicle]) -> ParkingBoard {
        ParkingBoard(
            villaName: villaName,
            myUnit: myUnit,
            spots: slots.map { $0.toSpot() },
            myVehicles: myVehicles
        )
    }
}

extension ParkingBoardResponse.Slot {
    /// 앱의 주차면으로 변환 - 남의 차는 뒤 4자리만 받는다
    func toSpot() -> ParkingSpot {
        ParkingSpot(
            number: slotId,
            assignedUnit: assignedUnitNumber,
            status: spotStatus,
            currentParking: occupant.map {
                ParkingRecord(plateNumber: $0.plateNumber ?? $0.plateLast4, enteredAt: $0.since, method: .manual)
            },
            unidentifiedReportId: unidentifiedReportId
        )
    }
    
    /// 서버 상태 글자를 앱 상태로
    var spotStatus: ParkingSpotStatus {
        switch status {
        case "OCCUPIED": .occupied
        case "VISITING": .visiting
        case "UNIDENTIFIED": .unconfirmed
        case "NEEDS_CHECK": .needsCheck
        case "AVAILABLE": .available
            // 방문 예정은 아직 차가 없어서 빈 면으로 보여 준다
        case "EMPTY", "VISIT_SCHEDULED": .empty
        default: .needsCheck // 앱이 아직 모르는 상태는 확인 필요로 표시
        }
    }
}
