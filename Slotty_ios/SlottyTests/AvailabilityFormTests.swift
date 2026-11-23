//
//  AvailabilityFormTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 가용시간 등록 입력 검사와 서버 요청
@MainActor
struct AvailabilityFormTests {
    @Test func 반복인데_요일이_없으면_막힌다() {
        #expect(AvailabilityForm().problem == "요일을 골라 주세요")
    }

    @Test func 요일은_월요일부터_순서대로_보낸다() {
        var form = AvailabilityForm()
        form.days = ["FRI", "MON"]
        form.allDay = false

        let request = form.request(spotNumber: 1)

        #expect(request.days == ["MON", "FRI"])
        #expect(request.startTime == "09:00")
        #expect(request.targetDate == nil)
    }

    @Test func 시각은_30분_단위로_고른다() {
        #expect(AvailabilityForm.times.first == "00:00")
        #expect(AvailabilityForm.times[1] == "00:30")
        #expect(AvailabilityForm.times.last == "23:30")
    }

    @Test func 오늘만_빼면_빼는_날에_들어간다() async throws {
        let viewModel = AvailabilityViewModel(repository: MockAvailabilityRepository(), spotNumber: 1)
        await viewModel.load()
        let item = try #require(viewModel.items?.first)

        await viewModel.skipToday(item)

        #expect(viewModel.items?.first?.skippedDates == [AvailabilityForm.dateString(Date())])
    }
}
