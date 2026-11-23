//
//  AvailabilityTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 가용시간 응답 해석과 요약 문구
@MainActor
struct AvailabilityTests {
    @Test func 반복_가용시간은_요일과_시간으로_요약한다() throws {
        let json = #"[{ "availabilityId": 1, "slotId": 1, "slotLabel": "1번", "isRecurring": true, "days": ["MON", "WED"], "targetDate": null, "allDay": false, "startTime": "09:00", "endTime": "18:00", "skippedDates": ["2026-11-24"] }]"#
        
        let items = try JSONDecoder().decode([AvailabilityResponse].self, from: Data(json.utf8)).map { $0.toAvailability() }
        
        #expect(items[0].summary == "매주 월 수 · 09:00~18:00")
        #expect(items[0].skippedDates == ["2026-11-24"])
    }
    
    @Test func 하루만_종일이면_날짜와_종일로_요약한다() throws {
        let json = #"[{ "availabilityId": 2, "slotId": 1, "slotLabel": "1번", "isRecurring": false, "days": null, "targetDate": "2026-11-25", "allDay": true, "startTime": null, "endTime": null, "skippedDates": [] }]"#
        
        let items = try JSONDecoder().decode([AvailabilityResponse].self, from: Data(json.utf8)).map { $0.toAvailability() }
        
        #expect(items[0].summary == "2026-11-25 · 종일")
    }
}
