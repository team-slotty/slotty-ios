//
//  VisitAPITests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 서버 방문 - 세 구간을 합치고, 시각은 +09:00으로 보낸다
@MainActor
@Suite(.serialized)
struct VisitAPITests {
    private let host = "visit.test"
    
    @Test func 예정_방문_중_지난_방문을_합친다() async throws {
        StubURLProtocol.handlers[host] = { request in
            let item: String
            switch request.url?.query {
            case "scope=UPCOMING":
                item = #"{ "visitId": 1, "plateNumber": "56바7890", "startAt": "2026-11-24T14:00:00", "endAt": "2026-11-24T18:00:00", "slotId": 7, "slotCancelledAt": null, "state": "SCHEDULED", "endedAt": null }"#
            case "scope=ONGOING":
                item = #"{ "visitId": 2, "plateNumber": "78마3456", "startAt": "2026-11-23T09:00:00", "endAt": "2026-11-23T18:00:00", "slotId": 6, "slotCancelledAt": "2026-11-23T10:00:00", "state": "ONGOING", "endedAt": null }"#
            default:
                return (200, #"{ "items": [], "page": 0, "size": 20, "total": 0 }"#)
            }
            return (200, #"{ "items": [\#(item)], "page": 0, "size": 20, "total": 1 }"#)
        }
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: InMemoryTokenStore())
        
        let visits = try await LiveVisitRepository(client: client).fetchVisits()
        
        #expect(visits.map(\.id) == ["1", "2"])
        #expect(visits[0].spotNumber == 7)
        // 면 지정이 취소된 방문은 면이 없는 방문으로
        #expect(visits[1].spotNumber == nil)
    }
    
    @Test func 방문_시각은_한국_시각에_09_00을_붙여_보낸다() throws {
        let startAt = try #require(ISO8601DateFormatter().date(from: "2026-11-23T05:00:00Z"))
        let request = VisitCreateRequest(plateNumber: "56바7890", startAt: startAt, endAt: startAt, slotId: nil)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom(APIClient.encodeServerDate)
        
        let json = try #require(String(data: encoder.encode(request), encoding: .utf8))
        
        #expect(json.contains("2026-11-23T14:00:00+09:00"))
    }
    
    @Test func 지정_가능_면은_시각의_더하기를_인코딩해서_묻는다() async throws {
        StubURLProtocol.handlers[host] = { request in
            // +09:00의 +가 %2B로 가야 서버가 공백으로 읽지 않는다
            let query = request.url?.query ?? ""
            guard query.contains("startAt=2026-11-23T14:00:00%2B09:00") else { return (400, "") }
            return (200, #"[{ "slotId": 6, "label": "6번", "type": "COMMON", "assignedUnitNumber": null, "allDay": true, "window": null }]"#)
        }
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: InMemoryTokenStore())
        let startAt = try #require(ISO8601DateFormatter().date(from: "2026-11-23T05:00:00Z"))
        
        let spots = try await LiveVisitRepository(client: client).availableSpotNumbers(startAt: startAt, endAt: startAt.addingTimeInterval(3600))
        
        #expect(spots == [6])
    }
}
