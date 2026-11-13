//
//  ParkingSpot.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation

/// 주차장의 주차면 하나
struct ParkingSpot: Identifiable, Equatable {
    /// 면 번호
    let number: Int
    /// 배정된 세대 호수, nil일 경우 공통 면
    let assignedUnit: String?
    /// 지금 상태
    var status: ParkingSpotStatus
    /// 지금 서 있는 차의 기록, 비어 있으면 nil
    var currentParking: ParkingRecord?
    
    var id: Int { number }
    
    /// 배정 세대가 없는 공용 면인지
    var isShared: Bool {
        assignedUnit == nil
    }
    
    /// 이 세대에 배정된 면인지
    func isAssigned(to unit: String) -> Bool {
        assignedUnit == unit
    }
}
