//
//  VehicleRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 우리 세대 차량 등록 약속
protocol VehicleRepository {
    /// 차량 등록 - 연락 담당자는 본인
    func register(plateNumber: String) async throws
}
