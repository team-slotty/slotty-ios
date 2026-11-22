//
//  VehicleRepositoryTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation
import Testing
@testable import Slotty

/// 차량 등록 저장소
@MainActor
struct VehicleRepositoryTests {
    @Test func 등록_응답을_읽는다() throws {
        let json = #"{ "vehicleId": 9, "plateNumber": "12가3456", "contactUser": { "userId": 5, "name": "이수진" } }"#
        
        let response = try JSONDecoder().decode(VehicleResponse.self, from: Data(json.utf8))
        
        #expect(response.vehicleId == 9)
        #expect(response.plateNumber == "12가3456")
    }
    
    @Test func 같은_번호는_두_번_등록할_수_없다() async throws {
        let repository = MockVehicleRepository()
        try await repository.register(plateNumber: "56바7890")
        
        await #expect(throws: VehicleError.plateDuplicated) {
            try await repository.register(plateNumber: "56바7890")
        }
    }
}
