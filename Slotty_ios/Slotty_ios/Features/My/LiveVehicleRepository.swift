//
//  LiveVehicleRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 서버와 통신하는 차량 저장소
struct LiveVehicleRepository: VehicleRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func fetchVehicles() async throws -> [RegisteredVehicle] {
        let response: [VehicleResponse] = try await client.get("/api/vehicles")
        return response.map { $0.toRegisteredVehicle() }
    }
    
    /// contactUserId를 보내지 않으면 서버가 본인을 담당자로 정한다
    func register(plateNumber: String) async throws {
        let request = VehicleCreateRequest(plateNumber: plateNumber)
        let _: VehicleResponse = try await client.post("/api/vehicles", body: request)
    }
    
    func delete(vehicleId: Int) async throws {
        try await client.delete("/api/vehicles/\(vehicleId)")
    }
    
    func fetchMembers() async throws -> [HouseholdMember] {
        let response: MyHouseholdResponse = try await client.get("/api/households/me")
        return response.members.map { HouseholdMember(id: $0.userId, name: $0.name) }
    }
    
    /// 담당자만 보내서 차량번호는 그대로 둔다
    func updateContact(vehicleId: Int, contactUserId: Int) async throws {
        let _: VehicleResponse = try await client.patch(
            "/api/vehicles/\(vehicleId)",
            body: VehicleUpdateRequest(contactUserId: contactUserId)
        )
    }
}
