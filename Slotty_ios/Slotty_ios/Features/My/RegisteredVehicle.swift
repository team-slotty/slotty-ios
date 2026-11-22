//
//  RegisteredVehicle.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 내 차량 관리에 보이는 우리 세대 등록 차량
struct RegisteredVehicle: Identifiable, Equatable {
    /// 서버의 vehicleId
    let id: Int
    /// 차량번호 (예: 12가3456)
    let plateNumber: String
    /// 연락 담당자 이름, 지정 전이면 nil
    let contactName: String?
}
