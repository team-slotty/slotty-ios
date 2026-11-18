//
//  ParkingBoard.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation

/// 홈 현황판에 필요한 정보 묶음
struct ParkingBoard: Equatable {
    /// 빌라 이름 (예: 역삼 그린빌)
    let villaName: String
    /// 내 세대 호수 (예: 201)
    let myUnit: String
    /// 주차면 목록 (면 번호 순)
    var spots: [ParkingSpot]
    /// 우리 세대 차량
    var myVehicles: [Vehicle]
    
    /// 이 차가 서 있는 면, 주차 안 했으면 nil
    func spot(parkedBy vehicle: Vehicle) -> ParkingSpot? {
        spots.first { $0.currentParking?.plateNumber == vehicle.plateNumber }
    }
    /// 방문 차량에 지정할 수 있는 면 - 공용 면과 가용시간 중인 면
    var visitorSpotNumbers: [Int] {
        spots.filter { $0.isShared || $0.status == .available }.map(\.number)
    }
}
