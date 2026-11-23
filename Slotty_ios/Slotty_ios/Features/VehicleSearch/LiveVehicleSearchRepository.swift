//
//  LiveVehicleSearchRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 서버와 통신하는 차량 검색 저장소
struct LiveVehicleSearchRepository: VehicleSearchRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func search(last4: String) async throws -> VehicleSearchResults {
        let response: VehicleSearchResponse = try await client.get(
            "/api/vehicles/search",
            query: [URLQueryItem(name: "plate", value: last4)]
        )
        return response.toResults()
    }
}
