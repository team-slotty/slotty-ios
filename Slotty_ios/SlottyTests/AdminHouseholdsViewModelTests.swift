//
//  AdminHouseholdsViewModelTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 관리 탭 세대 추가/삭제와 서버 거절
@MainActor
@Suite(.serialized)
struct AdminHouseholdsViewModelTests {
    @Test func 세대를_추가하면_목록에_보인다() async {
        let viewModel = AdminHouseholdsViewModel(repository: MockAdminRepository())
        
        await viewModel.add(unitNumber: " 401 ")
        
        #expect(viewModel.households?.contains { $0.unitNumber == "401" } == true)
    }
    
    @Test func 세대원이_남은_세대는_삭제가_거절된다() async {
        let host = "admin.test"
        StubURLProtocol.handlers[host] = { request in
            request.httpMethod == "DELETE"
            ? (409, #"{ "code": "HOUSEHOLD_NOT_EMPTY", "message": "가입자나 차량이 남아 있는 세대는 삭제할 수 없습니다.", "details": {} }"#)
            : (200, "[]")
        }
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: InMemoryTokenStore())
        let viewModel = AdminHouseholdsViewModel(repository: LiveAdminRepository(client: client))
        let household = AdminHousehold(id: 1, unitNumber: "101", inviteCode: "SEED101AAAA", spotLabels: [], vehicleCount: 2, members: [])
        
        await viewModel.delete(household)
        
        #expect(viewModel.errorMessage == "가입자나 차량이 남아 있는 세대는 삭제할 수 없습니다.")
    }
}
