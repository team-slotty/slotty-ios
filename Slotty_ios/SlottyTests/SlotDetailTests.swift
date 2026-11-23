//
//  SlotDetailTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 면 상세 응답 해석
@MainActor
struct SlotDetailTests {
    @Test func 가용시간이_종일이면_종일로_보인다() throws {
        let json = #"{ "slotId": 1, "label": "1번", "status": "AVAILABLE", "availableWindow": { "allDay": true, "startTime": null, "endTime": null }, "visit": null }"#
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(APIClient.decodeServerDate)
        
        let detail = try decoder.decode(SlotDetailResponse.self, from: Data(json.utf8)).toDetail()
        
        #expect(detail.availableTime == "종일")
        #expect(detail.visit == nil)
    }
    
    @Test func 시간이_정해진_가용시간은_시작과_끝을_보인다() throws {
        let json = #"{ "availableWindow": { "allDay": false, "startTime": "09:00", "endTime": "18:00" }, "visit": null }"#
        
        let detail = try JSONDecoder().decode(SlotDetailResponse.self, from: Data(json.utf8)).toDetail()
        
        #expect(detail.availableTime == "09:00~18:00")
    }
}
