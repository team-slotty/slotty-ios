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
    
    /// contactUserId를 보내지 않으면 서버가 본인을 담당자로 정한다
    func register(plateNumber: String) async throws {
        let request = VehicleCreateRequest(plateNumber: plateNumber)
        let _: VehicleResponse = try await client.post("/api/vehicles", body: request)
    }
}
