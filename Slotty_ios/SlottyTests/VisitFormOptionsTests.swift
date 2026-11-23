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
}
