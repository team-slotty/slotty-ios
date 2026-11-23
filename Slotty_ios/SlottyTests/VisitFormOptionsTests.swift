//
//  VisitFormOptionsTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 방문 등록 화면에서 고를 면과 자주 오는 차
@MainActor
struct VisitFormOptionsTests {
    private let viewModel = VisitListViewModel(repository: MockVisitRepository())
    
    @Test func 그_시간에_지정할_수_있는_면을_받는다() async {
        let now = Date()
        
        let spots = await viewModel.availableSpotNumbers(startAt: now, endAt: now.addingTimeInterval(3600))
        
        #expect(spots == [6, 7])
    }
    
    @Test func 자주_오는_차를_받는다() async {
        #expect(await viewModel.frequentPlateNumbers() == ["78마3456", "56바7890"])
    }
    
    @Test func 서버_실패면_서버_문구를_남긴다() async {
        let host = "visit-error.test"
        StubURLProtocol.handlers[host] = { _ in
            (409, #"{ "code": "VISIT_OVERLAP", "message": "같은 면에 시간이 겹치는 방문이 있습니다.", "details": {} }"#)
        }
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: InMemoryTokenStore())
        let viewModel = VisitListViewModel(repository: LiveVisitRepository(client: client))
        var form = VisitForm()
        form.plateNumber = "56바7890"
        
        #expect(await viewModel.register(form) == false)
        #expect(viewModel.actionErrorMessage == "같은 면에 시간이 겹치는 방문이 있습니다.")
    }
}
