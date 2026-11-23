//
//  AdminRepositoryTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 관리자 세대 목록 해석
@MainActor
struct AdminRepositoryTests {
    @Test func 세대_목록을_읽는다() throws {
        let json = #"[{ "householdId": 1, "unitNumber": "101", "inviteCode": "SEED101AAAA", "slotLabels": ["1번"], "vehicleCount": 2, "members": [{ "userId": 1, "name": "김민준", "isAdmin": true }] }]"#
        
        let households = try JSONDecoder().decode([HouseholdSummaryResponse].self, from: Data(json.utf8)).map { $0.toHousehold() }
        
        #expect(households[0].inviteCode == "SEED101AAAA")
        #expect(households[0].members[0].isAdmin)
    }
}
