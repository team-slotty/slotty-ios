//
//  MyVehiclesMappingTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation
import Testing
@testable import Slotty

/// 내 차량 응답 해석과 앱 차량 변환
@MainActor
struct MyVehiclesMappingTests {
    /// 백엔드가 알려 준 응답 예시 그대로
    private let json = """
        {
          "unitNumber": "101",
          "vehicles": [
            { "vehicleId": 1, "plateNumber": "12가3456", "state": "PARKED", "slotNumber": 1 },
            { "vehicleId": 5, "plateNumber": "90마2468", "state": "DRIVING", "slotNumber": null }
          ]
        }
        """
    
    private func decode() throws -> MyVehiclesResponse {
        try JSONDecoder().decode(MyVehiclesResponse.self, from: Data(json.utf8))
    }
    
    @Test func 주차_중이_아니면_면_번호가_nil이다() throws {
        let response = try decode()
        #expect(response.vehicles[0].slotNumber == 1)
        #expect(response.vehicles[1].slotNumber == nil)
    }
    
    @Test func 앱_차량으로_바꾸면_세대와_id가_채워진다() throws {
        let vehicles = try decode().toVehicles()
        #expect(vehicles == [
            Vehicle(id: "1", plateNumber: "12가3456", nickname: nil, unit: "101"),
            Vehicle(id: "5", plateNumber: "90마2468", nickname: nil, unit: "101"),
        ])
        
    }
}
