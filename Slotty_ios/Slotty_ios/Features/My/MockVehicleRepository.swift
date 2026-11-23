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
    
    private let members = [HouseholdMember(id: 1, name: "김민준"), HouseholdMember(id: 5, name: "이수진")]
    
    func fetchMembers() async throws -> [HouseholdMember] {
        members
    }
    
    func updateContact(vehicleId: Int, contactUserId: Int) async throws {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicleId }),
              let member = members.first(where: { $0.id == contactUserId })
        else { return }
        let vehicle = vehicles[index]
        vehicles[index] = RegisteredVehicle(id: vehicle.id, plateNumber: vehicle.plateNumber, contactName: member.name, contactUserId: member.id)
    }
}

/// 차량 등록 중에 생길 수 있는 오류
enum VehicleError: Error, Equatable {
    /// 같은 빌라에 이미 있는 차량번호
    case plateDuplicated
}
