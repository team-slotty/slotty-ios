//
//  CheckInOptionsTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation
import Testing
@testable import Slotty

/// 입차할 때 고를 수 있는 면
@MainActor
struct CheckInOptionsTests {
    @Test func 서버_응답을_면_번호로_바꾼다() throws {
        // 백엔드가 알려 준 응답 예시 그대로 (kim101: 배정 면이 차 있어 공용 6번만)
        let json = """
            {
              "mode": "AUTO",
              "vehicles": [{ "vehicleId": 5, "plateNumber": "90마2468", "state": "DRIVING", "parkedSlotLabel": null }],
              "suggestedVehicleId": 5,
              "slots": {
                "suggestedSlotId": null,
                "assignedAllOccupied": true,
                "options": [{ "slotId": 6, "label": "6번", "type": "COMMON" }]
              }
            }
            """

        let response = try JSONDecoder().decode(CheckInOptionsResponse.self, from: Data(json.utf8))

        #expect(response.toOptions() == CheckInOptions(spotNumbers: [6], suggestedSpotNumber: nil, assignedAllOccupied: true))
    }

    @Test func 목_저장소도_빈_내_면과_빈_공용_면만_준다() async throws {
        let repository = MockParkingRepository()
        let board = try await repository.fetchBoard()

        let options = try await repository.checkInOptions()

        let selectable = board.spots.filter { options.spotNumbers.contains($0.number) }
        #expect(selectable.allSatisfy { !$0.status.isOccupied })
        #expect(selectable.allSatisfy { $0.isShared || $0.isAssigned(to: board.myUnit) })
    }
}
