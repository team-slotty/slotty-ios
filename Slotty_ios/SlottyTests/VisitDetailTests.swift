//
//  VisitDetailTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 방문 상세와 수정
@MainActor
struct VisitDetailTests {
    @Test func 연락처는_공개했을_때만_보인다() throws {
        let json = #"{ "visitId": 1, "registeredBy": { "userId": 1, "name": "김민준" }, "contact": { "canCall": false, "phone": null } }"#
        
        let detail = try JSONDecoder().decode(VisitDetailResponse.self, from: Data(json.utf8)).toDetail()
        
        #expect(detail.registeredBy == "김민준")
        #expect(detail.phoneNumber == nil)
    }
    
    @Test func 시작_전_방문만_수정할_수_있다() async throws {
        let repository = MockVisitRepository()
        let visits = try await repository.fetchVisits()
        let scheduled = try #require(visits.first { $0.canDelete() })
        let visiting = try #require(visits.first { $0.canEnd() })
        
        let updated = try await repository.update(visitID: scheduled.id, plateNumber: "11가1111", startAt: scheduled.startAt, endAt: scheduled.endAt, spotNumber: nil)
        
        #expect(updated.plateNumber == "11가1111")
        await #expect(throws: VisitError.alreadyStarted) {
            _ = try await repository.update(visitID: visiting.id, plateNumber: "11가1111", startAt: visiting.startAt, endAt: visiting.endAt, spotNumber: nil)
        }
    }
}
