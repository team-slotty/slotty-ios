//
//  TodayVisitsTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation
import Testing
@testable import Slotty

/// 홈 "오늘 방문 예정" 에 들어가는 방문
@MainActor
struct TodayVisitsTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        return calendar
    }()
    
    /// 2026년 11월 day일 hour시 (한국 시간)
    private func date(day: Int = 18, hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour))!
    }
    
    /// 지금 = 11월 18일 10시
    private var now: Date { date(hour: 10) }
    
    @Test func 오늘_오후_방문은_들어간다() {
        let visit = Visit(id: "v", plateNumber: "12가3456", startAt: date(hour: 14), endAt: date(hour: 18))
        #expect(visit.isUpcomingToday(at: now, calendar: calendar))
    }
    
    @Test func 내일_방문은_빠진다() {
        let visit = Visit(id: "v", plateNumber: "12가3456", startAt: date(day: 19, hour: 9), endAt: date(day: 19, hour: 12))
        #expect(!visit.isUpcomingToday(at: now, calendar: calendar))
    }
    
    @Test func 어제부터_이어진_방문_중은_들어간다() {
        let visit = Visit(id: "v", plateNumber: "12가3456", startAt: date(day: 17, hour: 22), endAt: date(hour: 12))
        #expect(visit.isUpcomingToday(at: now, calendar: calendar))
    }
    
    @Test func 일찍_끝낸_방문은_빠진다() {
        let visit = Visit(
            id: "v", plateNumber: "12가3456", startAt: date(hour: 8), endAt: date(hour: 12),
            endedAt: date(hour: 9)
        )
        #expect(!visit.isUpcomingToday(at: now, calendar: calendar))
    }
    
    @Test func 목_데이터에서는_방문_중_1건만_보인다() async {
        let viewModel = VisitListViewModel(repository: MockVisitRepository())
        await viewModel.load()
        #expect(viewModel.todayVisits().map(\.plateNumber) == ["78마3456"])
    }
}
