//
//  MockVehicleRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 목 데이터로 동작하는 차량 저장소 - 같은 번호는 한 번만 등록된다
final class MockVehicleRepository: VehicleRepository {
    private var vehicles = [
        RegisteredVehicle(id: 1, plateNumber: "12가3456", contactName: "김민준"),
        RegisteredVehicle(id: 5, plateNumber: "90마2468", contactName: nil),
    ]
    
    func fetchVehicles() async throws -> [RegisteredVehicle] {
        vehicles
    }
    
    func register(plateNumber: String) async throws {
        guard !vehicles.contains(where: { $0.plateNumber == plateNumber }) else {
            throw VehicleError.plateDuplicated
        }
        let nextID = (vehicles.map(\.id).max() ?? 0) + 1
        vehicles.append(RegisteredVehicle(id: nextID, plateNumber: plateNumber, contactName: "김민준"))
    }
    
    func delete(vehicleId: Int) async throws {
        vehicles.removeAll { $0.id == vehicleId }
    }
}

/// 차량 등록 중에 생길 수 있는 오류
enum VehicleError: Error, Equatable {
    /// 같은 빌라에 이미 있는 차량번호
    case plateDuplicated
}
