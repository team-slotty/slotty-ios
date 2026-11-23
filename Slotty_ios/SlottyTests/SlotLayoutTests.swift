//
//  SlotLayoutTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Testing
@testable import Slotty

/// 서버와 같은 배치 계산
@MainActor
struct SlotLayoutTests {
    @Test func 두_줄_배치는_위_줄이_하나_더_많다() {
        let slots = SlotLayout.calculate(template: "DOUBLE", entranceSide: "BOTTOM", count: 7)
        
        #expect(slots.filter { $0.y == 0.25 }.count == 4)
        #expect(slots.filter { $0.y == 0.65 }.count == 3)
        // 0.05~0.95를 4칸으로 나눈 첫 칸 가운데
        #expect(abs(slots[0].x - 0.1625) < 0.0001)
    }
    
    @Test func ㄱ자_배치는_3분의_1이_세로_줄이다() {
        let slots = SlotLayout.calculate(template: "L_SHAPE", entranceSide: "BOTTOM", count: 6)
        
        #expect(slots.filter { $0.rotation == 90 }.count == 2)
    }
    
    @Test func 입구가_왼쪽이면_가로와_세로를_바꾼다() {
        let bottom = SlotLayout.calculate(template: "LINE", entranceSide: "BOTTOM", count: 3)[0]
        let left = SlotLayout.calculate(template: "LINE", entranceSide: "LEFT", count: 3)[0]
        
        #expect(left.x == 1 - bottom.y)
        #expect(left.y == bottom.x)
        #expect(left.width == bottom.height)
        #expect(left.rotation == 90)
    }
}
