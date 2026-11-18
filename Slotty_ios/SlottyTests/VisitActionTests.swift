//
//  VisitActionTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation
import Testing
@testable import Slotty

/// 방문 종료와 삭제
@MainActor
struct VisitActionTests {
    private let now = Date()
    private let hour: TimeInterval = 60 * 60
    
    @Test func 시작_전_방문은_삭제만_할_수_있다() {
        let visit = Visit(id: "v", plateNumber: "12가3456", startAt: now + hour, endAt: now + 2 * hour)
        #expect(visit.canDelete(at: now))
        #expect(!visit.canEnd(at: now))
    }
    
    @Test func 확인_필요_방문은_종료할_수_있다() {
        let visit = Visit(
            id: "v", plateNumber: "12가3456", startAt: now - 3 * hour, endAt: now - hour, spotNumber: 7
        )
        #expect(visit.status(at: now) == .needsCheck)
        #expect(visit.canEnd(at: now))
        #expect(!visit.canDelete(at: now))
    }
    
    @Test func 방문_중을_종료하면_지난_방문으로_옮겨진다() async {
        let viewModel = VisitListViewModel(repository: MockVisitRepository())
        await viewModel.load()
        let visiting = viewModel.visits(in: .visiting)[0]
        #expect(await viewModel.end(visiting))
        #expect(viewModel.visits(in: .visiting).isEmpty)
        #expect(viewModel.visits(in: .ended).contains { $0.id == visiting.id })
    }
    
    @Test func 시작한_방문은_삭제되지_않는다() async {
        let viewModel = VisitListViewModel(repository: MockVisitRepository())
        await viewModel.load()
        let visiting = viewModel.visits(in: .visiting)[0]
        #expect(await viewModel.delete(visiting) == false)
        #expect(viewModel.visits?.count == 3)
    }
}
