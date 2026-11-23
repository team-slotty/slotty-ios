//
//  VisitFilterTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Testing
@testable import Slotty

/// 방문 상태에 맞는 구분 탭
@MainActor
struct VisitFilterTests {
    @Test(arguments: [
        (VisitStatus.scheduled, VisitFilter.scheduled),
        (.visiting, .visiting),
        (.needsCheck, .visiting),
        (.ended, .ended),
    ])
    func 상태에_맞는_탭을_고른다(status: VisitStatus, expected: VisitFilter) {
        #expect(VisitFilter(status: status) == expected)
        // 고른 탭에 그 상태가 실제로 들어가는지
        #expect(VisitFilter(status: status).contains(status))
    }
}
