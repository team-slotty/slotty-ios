//
//  VehicleSearchMappingTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 차량번호 검색 응답 해석과 서버 요청 주소
@MainActor
@Suite(.serialized)
struct VehicleSearchMappingTests {
    private let json = """
        {
          "remainingToday": 19,
          "results": [
            { "type": "RESIDENT", "unitNumber": "201", "plateLast4": "3456", "plateNumber": null, "visit": null,
              "contact": { "canCall": true, "phone": "010-0000-0002" } },
            { "type": "VISIT", "unitNumber": "101", "plateLast4": "3456", "plateNumber": "78마3456",
              "visit": { "visitId": 3, "startAt": "2026-11-23T14:00:00", "endAt": "2026-11-23T18:00:00", "slotLabel": "7번" },
              "contact": { "canCall": false, "phone": null } },
            { "type": "VISIT", "unitNumber": "302", "plateLast4": "3456", "plateNumber": null, "visit": null,
              "contact": { "canCall": false, "phone": null } }
          ]
        }
        """
    
    @Test func 남의_차는_뒤_4자리만_보이고_연락처는_공개할_때만() async throws {
        let host = "search.test"
        let json = json
        StubURLProtocol.handlers[host] = { request in
            // 검색어는 주소 뒤 ?plate=로 붙어야 한다
            request.url?.query == "plate=3456" ? (200, json) : (400, "")
        }
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: InMemoryTokenStore())
        
        let found = try await LiveVehicleSearchRepository(client: client).search(last4: "3456")
        
        #expect(found.remainingCount == 19)
        #expect(found.items[0].maskedPlateNumber == "**3456")
        #expect(found.items[0].phoneNumber == "010-0000-0002")
        #expect(found.items[1].maskedPlateNumber == "78마3456")
        #expect(found.items[1].phoneNumber == nil)
        #expect(found.items[2].kind == .visitor(start: nil, end: nil))
    }
}
