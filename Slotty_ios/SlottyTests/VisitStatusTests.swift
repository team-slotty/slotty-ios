//
//  VisitStatusTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation
import Testing
@testable import Slotty

/// 방문 시각 → 상태 계산
@MainActor
struct VisitStatusTests {
    /// 기준 방문: 시작부터 4시간
    private let start = Date(timeIntervalSince1970: 1_800_000_000)
    private var end: Date { start + 4 * 60 * 60 }
    
    private func visit(spotNumber: Int? = nil, endedAt: Date? = nil) -> Visit {
        Visit(id: "v", plateNumber: "12가3456", startAt: start, endAt: end, spotNumber: spotNumber, endedAt: endedAt)
    }
    
    @Test func 시작_전이면_방문_예정() {
        #expect(visit().status(at: start - 60) == .scheduled)
    }
    
    @Test func 시작과_종료_사이면_방문_중() {
        #expect(visit().status(at: start + 60) == .visiting)
    }
    
    @Test func 방문_종료를_누르면_지난_방문() {
        let early = start + 60 * 60
        #expect(visit(endedAt: early).status(at: early + 60) == .ended)
    }
    
    @Test func 면_지정_방문이_종료_30분_후에도_정리되지_않으면_확인_필요() {
        #expect(visit(spotNumber: 5).status(at: end + 31 * 60) == .needsCheck)
        #expect(visit(spotNumber: 5).status(at: end + 10 * 60) == .ended)
    }
    
    @Test func 면을_지정하지_않은_방문은_종료_후_지난_방문() {
        #expect(visit().status(at: end + 31 * 60) == .ended)
    }
}
