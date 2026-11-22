//
//  VehicleRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 우리 세대 차량 목록/등록/삭제 약속
protocol VehicleRepository {
    /// 우리 세대에 등록된 차량
    func fetchVehicles() async throws -> [RegisteredVehicle]
    /// 차량 등록 - 연락 담당자는 본인
    func register(plateNumber: String) async throws
    /// 차량 삭제 - 주차 중이면 그 기록도 지워져 면이 빈 면이 된다
    func delete(vehicleId: Int) async throws
}
