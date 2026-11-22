//
//  MockVehicleRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 목 데이터로 동작하는 차량 저장소 - 같은 번호는 한 번만 등록된다
final class MockVehicleRepository: VehicleRepository {
    /// 등록된 차량번호 (공백 없이)
    private var plateNumbers: Set<String> = ["12가3456", "90마2468"]
    
    func register(plateNumber: String) async throws {
        guard !plateNumbers.contains(plateNumber) else {
            throw VehicleError.plateDuplicated
        }
        plateNumbers.insert(plateNumber)
    }
}

/// 차량 등록 중에 생길 수 있는 오류
enum VehicleError: Error, Equatable {
    /// 같은 빌라에 이미 있는 차량번호
    case plateDuplicated
}
