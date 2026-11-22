//
//  HouseholdTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation
import Testing
@testable import Slotty

/// 세대 소속 확인과 초대 코드 참여
@MainActor
struct HouseholdTests {
    @Test func 내_정보의_household가_null이면_소속_전이다() throws {
        let json = #"{ "id": 5, "loginId": "sujin201", "name": "이수진", "isAdmin": false, "household": null, "villa": null }"#
        
        let response = try JSONDecoder().decode(MeResponse.self, from: Data(json.utf8))
        
        #expect(response.household == nil)
    }
    
    @Test func 내_정보에서_세대_호수를_읽는다() throws {
        let json = #"{ "id": 1, "household": { "id": 1, "unitNumber": "101", "assignedSlotIds": [1] } }"#
        
        let response = try JSONDecoder().decode(MeResponse.self, from: Data(json.utf8))
        
        #expect(response.household?.unitNumber == "101")
    }
    
    @Test func 초대_코드는_소문자와_공백도_괜찮다() async throws {
        let repository = MockHouseholdRepository(myUnit: nil)
        
        let unit = try await repository.join(inviteCode: " seed201cccc ")
        
        #expect(unit == "201")
        #expect(try await repository.fetchMyUnit() == "201")
    }
    
    @Test func 없는_초대_코드는_실패한다() async {
        let repository = MockHouseholdRepository(myUnit: nil)
        
        await #expect(throws: HouseholdError.inviteCodeInvalid) {
            _ = try await repository.join(inviteCode: "WRONG")
        }
    }
}
