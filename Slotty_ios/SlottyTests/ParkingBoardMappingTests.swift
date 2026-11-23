//
//  ParkingBoardMappingTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 현황판 v2 응답 해석
@MainActor
struct ParkingBoardMappingTests {
    @Test func 미확인_면은_기록_id를_갖고_남의_차는_뒤_4자리만() throws {
        let json = """
            {
              "serverTime": "2026-11-23T10:00:00", "anchorMissing": false, "myVehicles": [], "todayVisits": [],
              "slots": [
                { "slotId": 1, "label": "1번", "isCommon": false, "assignedUnitNumber": "101", "isMine": true, "status": "OCCUPIED",
                  "occupant": { "unitNumber": "101", "plateLast4": "3456", "plateNumber": "12가3456", "since": "2026-11-23T08:00:00" },
                  "availableWindow": null, "visit": null, "unidentifiedReportId": null },
                { "slotId": 3, "label": "3번", "isCommon": false, "assignedUnitNumber": "201", "isMine": false, "status": "OCCUPIED",
                  "occupant": { "unitNumber": "201", "plateLast4": "5678", "plateNumber": null, "since": "2026-11-23T09:00:00" },
                  "availableWindow": null, "visit": null, "unidentifiedReportId": null },
                { "slotId": 6, "label": "6번", "isCommon": true, "assignedUnitNumber": null, "isMine": false, "status": "UNIDENTIFIED",
                  "occupant": null, "availableWindow": null, "visit": null, "unidentifiedReportId": 12 }
              ]
            }
            """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(APIClient.decodeServerDate)
        
        let spots = try decoder.decode(ParkingBoardResponse.self, from: Data(json.utf8)).slots.map { $0.toSpot() }
        
        #expect(spots[0].currentParking?.plateNumber == "12가3456")
        #expect(spots[1].currentParking?.maskedPlateNumber == "**5678")
        #expect(spots[2].status == .unconfirmed)
        #expect(spots[2].unidentifiedReportId == 12)
    }
}
