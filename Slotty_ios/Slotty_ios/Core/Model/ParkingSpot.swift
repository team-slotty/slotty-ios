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
    /// 서버의 미확인 기록 id - 미확인 면이 아니거나 목 데이터면 nil
    var unidentifiedReportId: Int? = nil
    
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

/// 면 상세에서 더 보여 주는 정보 - 서버 면 상세에서 받는다
struct SpotDetail: Equatable {
    /// 가용시간 (예: 종일, 09:00~18:00), 가용시간이 아니면 nil
    let availableTime: String?
    /// 지정된 방문 (예: 101호 방문 14:00~18:00), 없거나 볼 권한이 없으면 nil
    let visit: String?
}
