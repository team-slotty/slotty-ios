//
//  ArrivalNotifierTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import CoreLocation
import Testing
import UserNotifications
@testable import Slotty

/// 도착 알림 요청 - 기준점 반경 150m, 들어올 때만
@MainActor
struct ArrivalNotifierTests {
    @Test func 기준점_반경_150m에_들어올_때만_알린다() throws {
        let request = ArrivalNotifier.request(latitude: 37.4822875, longitude: 126.8792969)
        
        let trigger = try #require(request.trigger as? UNLocationNotificationTrigger)
        let region = try #require(trigger.region as? CLCircularRegion)
        #expect(region.radius == 150)
        #expect(region.center.latitude == 37.4822875)
        #expect(region.notifyOnEntry)
        #expect(!region.notifyOnExit) 
        #expect(trigger.repeats)
    }
    
    @Test func 다시_예약하면_같은_이름으로_덮어쓴다() {
        let first = ArrivalNotifier.request(latitude: 37.0, longitude: 127.0)
        let second = ArrivalNotifier.request(latitude: 37.5, longitude: 127.5)
        
        #expect(first.identifier == second.identifier)
    }
}
