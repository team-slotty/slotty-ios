//
//  BoardResponse+Mapping.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation

extension BoardResponse {
    /// 앱 모델로 변환 - 서버 응답에 없는 내 세대/내 차량은 따로 받는다
    func toBoard(myUnit: String, myVehicles: [Vehicle]) -> ParkingBoard {
        ParkingBoard(
            villaName: villaName,
            myUnit: myUnit,
            spots: slots.map { $0.toSpot() },
            myVehicles: myVehicles
        )
    }
}

extension BoardResponse.Slot {
    /// 앱의 주차면으로 변환
    func toSpot() -> ParkingSpot {
        ParkingSpot(
            number: number,
            assignedUnit: assignedUnit,
            status: spotStatus,
            currentParking: occupant.map {
                // 서버에 기록 방식이 아직 없어서 임시로 직접 기록
                ParkingRecord(plateNumber: $0.plateNumber, enteredAt: $0.enteredAt, method: .manual)
            }
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
        case "EMPTY": .empty
        default: .needsCheck // 앱이 아직 모르는 상태는 확인 필요로 표시
        }
    }
}
