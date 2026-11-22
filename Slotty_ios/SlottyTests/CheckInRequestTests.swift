//
//  CheckInRequestTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation
import Testing
@testable import Slotty

/// 입차 요청 JSON
@MainActor
struct CheckInRequestTests {
    @Test func 서버가_정한_이름으로_보내고_입차_시각은_보내지_않는다() throws {
        let request = CheckInRequest(vehicleId: 5, slotId: 6, method: "MANUAL", clientRequestId: "id-1")

        let data = try JSONEncoder().encode(request)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(json["vehicleId"] as? Int == 5)
        #expect(json["slotId"] as? Int == 6)
        #expect(json["method"] as? String == "MANUAL")
        #expect(json["clientRequestId"] as? String == "id-1")
        #expect(json["enteredAt"] == nil)
    }
}
